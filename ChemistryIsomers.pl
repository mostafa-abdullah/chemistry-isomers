
straight_chain_alkane(0,[]).
straight_chain_alkane(1,[carb(h,h,h,h)]).
straight_chain_alkane(N,X):-N>1,
                            straight_chain_alkane(N,X,N).
straight_chain_alkane(N,[carb(h,h,h,c)|B],N):-N1 is N-1,
                                              straight_chain_alkane(N1,B,N).
straight_chain_alkane(1,[carb(c,h,h,h)],_).
straight_chain_alkane(Count,[carb(c,h,h,c)|B],N):-Count>1,
                                              Count\=N,
                                              N1 is Count-1,
                                              straight_chain_alkane(N1,B,N).
branch_name(S,N):-
                  S>0,
                  HS is S*2+1,
                  atomic_list_concat([c,S,h,HS],N).
branch_name(0,h).
add_branch_to_carbon(carb(C1,h,h,C2), BSize, ResC):-
                          branch_name(BSize,N),
                          ResC = carb(C1,N,h,C2).
add_branch_to_carbon(carb(C1,H,h,C2), BSize, ResC):-
                          H \= h,
                          branch_name(BSize,N),
                          H@<N,
                          ResC = carb(C1,H,N,C2).
add_branch_to_carbon(carb(C1,H,h,C2), BSize, ResC):-
                          H \= h,
                          branch_name(BSize,N),
                          H@>=N,
                          ResC = carb(C1,N,H,C2).
generate_all_numbers(0,[0]).
generate_all_numbers(N,L):-
            N>0,
            N2 is N-1,
            generate_all_numbers(N2,L2),
            L = [N|L2].
get_components(N,Comp):- get_components(N,Comp,N).
get_components(N,[N,0],0).
get_components(N,[Count,C2],Count):-
                                 Count>0,
                                 C2 is N-Count,
                                 C2 >= Count.
get_components(N,Components,Count):-
                           Count>0,
                           Count2 is Count-1,
                           get_components(N,Components,Count2).
branched_alkane(N,BA):-
                       N>3,
                       start(N,BA),
                       length(BA,S),
                       S<N.
start(N,[carb(h,h,h,c)|Rest]):-
                               Valid is N-1,
                            build_alkane(N,Rest,2, Valid, 1).
build_alkane(N,[carb(c,h,h,h)],N,_,_).
build_alkane(N,BA,Count,Valid, LeftLinear):-
                                  Count>1,
                                  Count<N,
                                  LeftValid is LeftLinear*2,
                                  RightValid is 2*(N-Count)//3,
                                  MaximumTemp is min(LeftValid,RightValid),
                                  Maximum is min(Valid,MaximumTemp),
                                  generate_all_numbers(Maximum,PossibleCarbons),
                                  build_atom(N,BA,Count,Valid,LeftLinear,PossibleCarbons).
build_atom(N,BA, Count, Valid, LeftLinear, [_|T]):-
                 build_atom(N,BA, Count, Valid, LeftLinear, T).
build_atom(N,[Current|Rest], Count, Valid, LeftLinear, [H|_]):-
                 get_components(H,[Up,Down]),
                 Remaining is N-H-Count,
                 Up =< LeftLinear, Down =< LeftLinear, Up =< Remaining, Down =< Remaining,
                 add_branch_to_carbon(carb(c,h,h,c), Up, Temp),
                 add_branch_to_carbon(Temp, Down, Current),
                 MaxBranch is max(Up,Down),
                 ValidForLeft is Valid-H,
                 ValidForCurrent is N - Count - H - MaxBranch,
                 NewValid is min(ValidForLeft, ValidForCurrent),
                 NewCount is Count+H+1,
                 NewLeftLinear is LeftLinear + 1,
                 build_alkane(N,Rest,NewCount,NewValid,NewLeftLinear).
isomers(N,[Out]):-
              N<4,
              straight_chain_alkane(N,Out).
isomers(N,A):-
              setof(BA,branched_alkane(N,BA),Z),
              remove_mirror(Z,A2),
              straight_chain_alkane(N,S),
              append(A2,[S],A).
remove_mirror([],[]).
remove_mirror([H|Rest],L):-
                        Rest\=[],
                         get_mirror(H,Carbon),
                         member(Carbon,Rest),
                         remove_mirror(Rest,L).
remove_mirror([H|Rest],L):-
                        get_mirror(H,Carbon),
                        \+ member(Carbon,Rest),
                         remove_mirror(Rest,L2),
                         L = [Carbon|L2].
get_mirror([H|T],O):-
                     remove_last(T,T2),
                     reverse(T2,Reveresed),
                     O2 = [H|Reveresed],
                     append(O2,[carb(c,h,h,h)],O).
remove_last([_],[]).
remove_last([H|T],L):-
                          T\=[],
                          remove_last(T,L2),
                          L = [H|L2].