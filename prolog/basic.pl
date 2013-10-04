concat([],L,L).
concat([T|Q],L2,[T|R]):-concat(Q,L2,R).

dimension([],0).
dimension([_|Q],Dim):-dimension(Q,Dim1),Dim is Dim1 + 1.

element_n(1,[T|_],T).
element_n(N,[_|Q],X):-element_n(N1,Q,X),N is N1 + 1.

ligne_n(N,Carre,L):-element_n(N,Carre,L).

colone_n(N,[T|Q],C):-element_n(N,T,X),colone_n(N,Q,C1),concat([X],C1,C).
colone_n(_,[],[]).

colones(I, Carre, [C|C1]):-colone_n(I,Carre,C),!,I1 is I -1, colones(I1, Carre, C1).
colones(0,_,[]).
colones(Carre,Cs):-dimension(Carre,Dim),colones(Dim,Carre,Cs).
