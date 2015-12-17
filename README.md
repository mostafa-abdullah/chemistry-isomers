# chemistry-isomers
Logic Programming: A program which generates all possible (possibly huge number) isomers for a certain number of carbon atoms.

# Part A:
-	straight_chain_alkane(N,X):
	This predicate generates the straight alkane of length N (i.e. it has no branches).
	It has two special cases: either N is 0 or 1. If N is 0, X is unified with an empty list. If N is 1, X is unified with [carb(h,h,h,h)].
	It calls a helper  straight_chain_alkane(Count,X,N) with a counter which starts from N to 1. If Count is N, then we add carb(h,h,h,c) as the first carbon atom to  the output list, then recurs with Count-1. When Count is less than N, carb(c,h,h,c) is added until Count reaches 1. carb(c,h,h,h) is finally added ending the recursion and the straight chain alkane is formed completely.

# Part B:
-	branched_alkane(N,BA):
	There’ s no branched alkane with 3 or less number of carbon atoms.
	This predicate calls the helper start(N,BA) which adds the first carbon atom to the rest of the branched alkane that will be formed by the helper predicate build_alkane(N,Rest,Count,Valid,LeftLinear).
	The variable Valid is the maximum number of carbon atoms that can be branched without leading to violation of the rule of the longest chain by already existing branches.
	N is the total number of carbon atoms, Count is the total number of already added carbon atoms including the current one, LeftLinear is the number of carbon atoms added on the longest chain (without the branches).
	build_alkane predicate determines the maximum number of atoms that can be branched from the current carbon atom by determining the minimum of the  2*LeftLinear  and 2*(N-Count)//3.
	2*LeftLinear can be branched as 1*LeftLinear to the upper carbon and 1*LeftLinear to the lower carbon.
	(N-Count) calculates the remaining carbon atoms that haven’t already been added to the alkane. The maximum distribution of remaining carbons is divide them equally among up,down and right. So the sum of the upper and down branches will be 2*(N-Count)//3.
	In order not to violate the chain by any of existing branches, we determine the minimum of Valid and the previously determined maximum number of carbons to be added to the branch.
	build_alkane then calls a helper generate_all_numbers(Maximum, PossibleCarbons) which generates numbers from 0 to the determined maximum Valid. Example:
?- generate_all_numbers(5,L).
L = [5, 4, 3, 2, 1, 0] ;
false.
	Finally build_alkane calls build_atom(N,BA,Count,Valid,LeftLinear,PossibleCarbons) predicate that builds the branch on every carbon atom with all the numbers generated in PossibleCarbons from generate_all_numbers predicate, then build_atom calls build_alkane again to go on with the next carbon atom in the branch.
	build_atom goes through recursion to pass through all the numbers of PossibleCarbons list.
	Second part of build_atom adds the branches to the current carbon atom using the number existing in the head of PossibleCarbons list.
	It calls get_components predicate which get possible combinations of 2 numbers which sum to the head of PossibleCarbons list holding the following constraints:
	The 1st number is less than or equal the 2nd number except if the first number is zero. Example:
?- get_components(4,L).
L = [2, 2] ;
L = [1, 3] ;
L = [4, 0] ;
false.
	The first number of the returned list represents the size of the upper branch, and the second one is the size of the lower holding the following constraints:
	Both the upper and lower size must be smaller than or equal LinearLeft and the remaining number of carbon atoms (Remaining is N-H-Count)
	Then we call build_alkane(N,Rest,NewCount,NewValid,NewLeftLinear) again to move on with the rest of the alkane list.
	Rest is the rest of alkane list without the current carbon atom or the previous ones. Rest will be built later on.
	NewCount is the new total number of carbon atoms after adding the upper and lower branches including the next one.
	NewValid is the new Valid for the next carbon atom. It is calculated as the minimum of the ValidForLeft and ValidForCurrent.
	ValidForLeft is maximum number of carbon atoms that won’t let any branch on the left side violate the longest chain. (ValidForLeft is Valid-H) Where H is the sum of number of carbon atoms added on upper and lower branches.
	ValidForCurrent is the maximum number carbon atoms that won’t let any branch on the current carbon violate the longest chain (ValidForCurrent is N - Count - H – MaxBranch) where MaxBranch is maximum of the branches up and down.
	N-Count –H is the remaining number of carbon atoms to be added. And in order not to violate the longest chain, the rest of the straight chain to be greater than or equal MaxBranch. So MaxBranch is subtracted from the remaining.
 
	When the Count in build_alkane reaches N (total number of carbon atoms) the recursion stops and carb(c,h,h,h) is added as the last element in the list to end up with the final result.
	The length of the generated branched alkane must be less than the total number of carbon atoms to make sure that the straight chain alkane is not generated within the output.

# Part C (BONUS):
-	isomers(N,A):
	There is only one isomer for number of carbons less than 4 which is the straight chain alkane.
	Isomers predicate generates a list of all possible outputs from branched_alkane of size N using setof predefined predicate.
	Isomers predicate then calls predicate remove_mirror(Input, Output) which removes the alkane whose mirror exists in the generated set then the straight chain alkane is appended to the output to generate all possible isomers.
	remove_mirror([H|Rest],L) calls the predicate get_mirror)H ,Mirr) which unifies Mirr to the mirror of the alkane H. If Mirr exits in the Rest, then H is removed, otherwise Mirr is added instead of it, then we proceed with Rest to remove mirrors from it.
	get_mirror(L,O) reverses the list L without changing the position of the first or last element. Example:
?- get_mirror([carb(h,h,h,c),carb(c,ch3,h,c),carb(c,h,h,c),carb(c,h,h,c),carb(c,h,h,h)],L).
L = [carb(h, h, h, c), carb(c, h, h, c), carb(c, h, h, c), carb(c, ch3, h, c), carb(c, h, h, h)] ;


# Predicates list:
•	Main predicates:
-	straight_chain_alkane(N,X)
-	branched_alkane(N,BA)
-	isomers(N,A)
•	Helper predicates:
-	branch_name(S,N)
-	add_branch_to_carbon(Carbon, BSize, ResC).
-	generate_all_numbers(N,L).
-	get_components(N,Components).
-	start(N,[H|T]).
-	build_alkane(N,BA,Count,Valid,LeftLinear)
-	build_atom(N,BA,Count,Valid,LeftLinear,[H|T])
-	remove_mirror([H|T],L)
-	get_mirror([H|T],O)
-	remove_last([H|T],L).
-	member(X,L).
-	reverse(L,Reveresed)
-	append(L1,L2,L)
-	setof(A,branched_alkane(N,A),Z)
-	length(L,M)
