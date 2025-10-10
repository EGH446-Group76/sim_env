# ======================================================================================================================================================
# #####################################################################################################################################[ Imports ]######
# ======================================================================================================================================================


import numpy		as np
import random		as rand
import math

from scipy.ndimage	import binary_dilation
from copy			import deepcopy



# ======================================================================================================================================================
# #########################################################################################################################[ Auxiliary Functions ]######
# ======================================================================================================================================================

# ================================================================================================== Coordinate Conversions:

def WP2I(WP:tuple)->tuple:
	"""### Waypoint to Matrix Index"""
	return ((int(WP[1]*10)-1), (int(WP[0]*10)-1))

def I2WP(Index:tuple)->tuple:
	"""### Matrix Index to Waypoint"""
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



# ======================================================================================================================================================
# ##################################################################################################################[ OfflinePathPlanner() Class ]######
# ======================================================================================================================================================
class OfflinePathPlanner:

# ================================================================================================== Initialization:
	def __init__(self, Mat:np.ndarray, AvoidanceRadius:int=4, NumGoalWaypoints:int=5, 
				 XWorldLimits:tuple=(1, 52),    YWorldLimits:tuple=(1, 41),
				 InitialPosition:tuple=(2, 2),  InitialOrientation:float=0.0,):


# ========================================================================= Assertions:
		
		if (not isinstance(WP_array, np.ndarray)):
			try:	WP_array = np.array(WP_array)
			except:	raise ValueError("Invalid Waypoint List")

		assert (len(Mat.shape) == 2), "Numpy Array must be 2-Dimensional"


# ========================================================================= Robot Initial Placement:

		self.Init_Pos			= InitialPosition
		self.Init_Heading		= InitialOrientation


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

		self.N_WP				=	NumGoalWaypoints

		self.Waypoints			=	self.__GenerateWaypoints()
		self.Ordered_Waypoints	=	self.__OrderWaypoints(self.Waypoints)							# ("Targets")


# =========================================================================  A-Star Properties:

		self.initial			=	tuple(WP2I(self.Init_Pos), set([]))


# ======================================================================================================================================================
# #########################################################################################################################[ Waypoint Generation ]######
# ======================================================================================================================================================
	
# ==================================================================================================

	def __GenerateWaypoints(self, Seed:int=0):
		
		if (Seed != 0):
			rand.seed(Seed)
			np.random.seed(Seed)

		WPs = []
		while len(WPs) < self.N_WP:
			x = round(self.LimX[0] + (self.LimX[1]-self.LimX[0]) * rand.random(), 1)
			y = round(self.LimY[0] + (self.LimY[1]-self.LimY[0]) * rand.random(), 1)
			WP = (x, y)
			if (WP2I(WP) in self.FreeCells_s) and (WP not in WPs): WPs.append(WP)

		self.Waypoints			=	np.array(WPs)
		self.Ordered_Waypoints	=	self.__OrderWaypoints(self.Waypoints)

		return self.Waypoints


# ==================================================================================================
	
	def __OrderWaypoints(self, WP_array:np.ndarray|list):
		
		WP_array = deepcopy(WP_array)

		if (not isinstance(WP_array, np.ndarray)):
			try:	WP_array = np.array(WP_array)
			except:	raise ValueError("Invalid Waypoint List")

		assert (len(WP_array.shape) == 2) and (WP_array.shape[1] == 2), "Numpy Array must be of shape (N, 2)"

		WP_ordered = []
		WP_list    = deepcopy(WP_array).tolist()

		CurrentPos = self.Init_Pos
		while len(WP_list) > 0:
			Distances = [math.dist(CurrentPos, WP) for WP in WP_list]
			MinIndex  = Distances.index(min(Distances))

			CurrentPos = WP_list.pop(MinIndex)
			WP_ordered.append(CurrentPos)

		return np.array(WP_ordered)

	

# ======================================================================================================================================================
# ##############################################################################################################################[ A-Star Methods ]######
# ======================================================================================================================================================


	def _IsLegalMove(self, State:tuple, DeltaPos:tuple)->bool:
		"""### Check if a Move is Legal"""
		return (VA(State, DeltaPos) in self.FreeCells_s)
	

	def _IsLegalAction(self, State:tuple, Action)->bool:
		"""### Check if an Action is Legal"""

		PossibleMoves	=	set([(1, 0), (-1, 0), (0, -1), (0, 1)])	# Up, Down, Left, Right
		if (Action in PossibleMoves): return self._IsLegalMove(State, Action)

		return (False)


# ==================================================================================================

	def actions(self, State:tuple)->list:
		"""### Get a List of Legal Actions from a State"""
		PossibleActions = {(0, -1): "Up", (0, +1): "Down", (-1, 0): "Left", (+1, 0): "Right"}
		return [PossibleActions[Action] for Action in PossibleActions if self._IsLegalAction(State, Action)]
	

# ==================================================================================================

	def _MakeMove(self, State:tuple, DeltaPos:tuple)->tuple:
		"""### Make a Move from a State"""
		return	VA(State, DeltaPos)


# ==================================================================================================

	def result(self, State:tuple, action:str)->tuple:
		
		assert action in self.actions(State), "Invalid Action"                          #[#[ Necessary Assertion ]#]#

		if   (action == "Up"):		return(self._MakeMove(State, (+1,  0)))
		elif (action == "Down"):	return(self._MakeMove(State, (-1,  0)))
		elif (action == "Left"):	return(self._MakeMove(State, ( 0, -1)))
		elif (action == "Right"):	return(self._MakeMove(State, ( 0, +1)))


# ==================================================================================================

	def goal_test(self, State:tuple):
		return bool(all((Box in self.Targets) for Box in State[1]))  # ( State[1] = Boxes )




# ======================================================================================================================================================
# #########################################################################################################################################[ END ]######
# ======================================================================================================================================================  

