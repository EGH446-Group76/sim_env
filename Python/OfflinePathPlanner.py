# ======================================================================================================================================================
# #####################################################################################################################################[ Imports ]######
# ======================================================================================================================================================


import numpy		as np
import random		as rand
import math

from scipy.ndimage			import binary_dilation
from scipy.spatial.distance	import cityblock		as ManDist
from copy					import deepcopy


import search



# ======================================================================================================================================================
# #########################################################################################################################[ Auxiliary Functions ]######
# ======================================================================================================================================================

# ================================================================================================== Coordinate Conversions:

def P2I(WP:tuple)->tuple:
	"""### Position to Matrix Index"""
	return ((int(WP[1]*10)-1), (int(WP[0]*10)-1))

def I2P(Index:tuple)->tuple:
	"""### Matrix Index to Position"""
	return (round((Index[1]+1)/10, 1), round((Index[0]+1)/10, 1))


# ================================================================================================== Vector Operations:

def VA(BasePos:tuple, DeltaPos:tuple)->tuple:
	"""### Vector Addition"""
	return ((BasePos[0] + DeltaPos[0]), (BasePos[1] + DeltaPos[1]))

def VR(BasePos:tuple)->tuple:
	"""### Vector Reversal"""
	return ((BasePos[1]), (BasePos[0]))

def VN(BasePos:tuple)->tuple:
	"""### Vector Negation"""
	return ((-BasePos[0]), (-BasePos[1]))


# ================================================================================================== Tuple Operations:

def T_Remove(Tup:tuple, Item)->tuple:
	"""### Remove an Item from a Tuple"""
	return tuple(x for x in Tup if x != Item)


# ======================================================================================================================================================
# ##################################################################################################################[ OfflinePathPlanner() Class ]######
# ======================================================================================================================================================
class OfflinePathPlanner(search.Problem):

# ================================================================================================== Initialization:
	def __init__(self, Mat:np.ndarray,			AvoidanceRadius:int=4, 
			  	 NumWaypoints:int=5,
				 XWorldLimits:tuple=(1, 52),	YWorldLimits:tuple=(1, 41),
				 InitialPosition:tuple=(2, 2),	InitialOrientation:float=0.0,):


# ========================================================================= Assertions:
		
		assert (isinstance(Mat, np.ndarray)),	"Map must be a Numpy Array"
		assert (len(Mat.shape) == 2),			"Numpy Array must be 2-Dimensional"


# ========================================================================= Robot Initial Placement:

		self.Init_Pos			=	InitialPosition
		self.Init_Heading		=	InitialOrientation


# ========================================================================= Map Properties:

		self.nRows				=	Mat.shape[0]
		self.nCols				=	Mat.shape[1]

		self.LimX 				=	XWorldLimits
		self.LimY 				=	YWorldLimits

		self.AvoidanceRadius 	=	AvoidanceRadius

		self.Walls_m			=	Mat
		self.V_Walls_m			=	binary_dilation(Mat, iterations=AvoidanceRadius).astype(Mat.dtype)
		self.WallPadding_m		=	(self.V_Walls_m ^ Mat).astype(Mat.dtype)

		self.V_Walls_s			=	set(map(tuple, np.argwhere(self.V_Walls_m)))					# ("Walls")
		self.FreeCells_s		=	set(map(tuple, np.argwhere(self.V_Walls_m == 0)))				# ("InsideCells")


# =========================================================================  Waypoint Generation:

		self.N_WP				=	NumWaypoints

		self.WPs_t				=	None															# ("Targets")
		self.GenerateWaypoints()

	Waypoints				=	property(lambda self: np.array(self.WPs_t))


# =========================================================================  A-Star Properties:

	initial					=	property(lambda self: tuple(P2I(self.Init_Pos), self.WPs_t))	# ("initial")



# ======================================================================================================================================================
# #########################################################################################################################[ Waypoint Generation ]######
# ======================================================================================================================================================
	
# ==================================================================================================

	def GenerateWaypoints(self, Seed:int=0):
		
		if (Seed != 0):
			rand.seed(Seed)
			np.random.seed(Seed)

		WPs = []
		while len(WPs) < self.N_WP:
			x = round(self.LimX[0] + (self.LimX[1]-self.LimX[0]) * rand.random(), 1)
			y = round(self.LimY[0] + (self.LimY[1]-self.LimY[0]) * rand.random(), 1)
			WP = (x, y)
			if (P2I(WP) in self.FreeCells_s) and (WP not in WPs): WPs.append(WP)

		self.WPs_t =	tuple(WPs)


# ==================================================================================================
	
	def OrderWaypoints(self, WPs, CurrentPos:tuple=None, ReturnDistances:bool=False)->tuple:
		
		if (CurrentPos is None): CurrentPos = P2I(self.Init_Pos)

		WP_ordered = []
		WP_list    = list(deepcopy(WPs))

		CurrentPos = self.Init_Pos
		while len(WP_list) > 0:
			Distances	= [ManDist(CurrentPos, WP) for WP in WP_list]
			MinDist		= min(Distances)
			MinIndex	= Distances.index(MinDist)

			CurrentPos = WP_list.pop(MinIndex)

			if (ReturnDistances):	WP_ordered.append(MinDist)
			else:					WP_ordered.append(CurrentPos)

		return tuple(WP_ordered)


# ======================================================================================================================================================
# ##############################################################################################################################[ A-Star Methods ]######
# ======================================================================================================================================================


	def _IsLegalMove(self, state:tuple[tuple, tuple], DeltaPos:tuple)->bool:
		"""### Check if a Move is Legal"""
		return (VA(state[0], DeltaPos) in self.FreeCells_s)
	

	def _IsLegalAction(self, state:tuple[tuple, tuple], action)->bool:
		"""### Check if an Action is Legal"""
		PossibleMoves	=	set([(1, 0), (-1, 0), (0, -1), (0, 1)])	# [(Up), (Down), (Left), (Right)]
		if (action in PossibleMoves): return self._IsLegalMove(state, action)

		return (False)


# ==================================================================================================

	def actions(self, state:tuple[tuple, tuple])->list:
		"""### Get a List of Legal Actions from a State"""
		PossibleActions = {(0, -1): "Up", (0, +1): "Down", (-1, 0): "Left", (+1, 0): "Right"}
		return [PossibleActions[Action] for Action in PossibleActions if self._IsLegalAction(state, Action)]
	

# ==================================================================================================

	def _MakeMove(self, state:tuple[tuple, tuple], DeltaPos:tuple)->tuple:
		"""### Make a Move from a State"""
		NewPos = VA(state[0], DeltaPos)
		return	tuple(NewPos, T_Remove(state[1], NewPos))


# ==================================================================================================

	def result(self, state:tuple[tuple, tuple], action:str)->tuple:
		
		assert action in self.actions(state), "Invalid Action"                          #[#[ Necessary Assertion ]#]#

		if   (action == "Up"):		return(self._MakeMove(state, (+1,  0)))
		elif (action == "Down"):	return(self._MakeMove(state, (-1,  0)))
		elif (action == "Left"):	return(self._MakeMove(state, ( 0, -1)))
		elif (action == "Right"):	return(self._MakeMove(state, ( 0, +1)))


# ==================================================================================================

	def goal_test(self, state:tuple[tuple, tuple])->bool:
		"""### Test if the State is a Goal State"""
		return (len(state[1]) == 0)	# (No Remaining Waypoints)


# ==================================================================================================

	def path_cost(self, c, state1:tuple[tuple, tuple], action:str, state2:tuple[tuple, tuple]):
		return (c + int(self.result(state1, action, ReturnCost=True, WithWeights=True)))                           ### [ With-Weights = True ] ###


# ==================================================================================================

	
	def h(self, node:search.Node):
		"""## The Heuristic Function"""

		(Pos, Remaining_WPs) = node.state

		if (len(Remaining_WPs) == 0): return 0

		return sum(self.OrderWaypoints(Remaining_WPs, CurrentPos=Pos, ReturnDistances=True))

		# return (min([math.dist(Pos, P2I(WP)) for WP in Remaining_WPs]))




		


# ======================================================================================================================================================
# #########################################################################################################################################[ END ]######
# ======================================================================================================================================================  

