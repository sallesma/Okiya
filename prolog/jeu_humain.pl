/* Constantes */
tuiles([[oiseau, erable],[tanzaku,iris] ,[soleil,erable], [pluie,cerisier], [tanzaku,pin], [oiseau,pin], [pluie,erable], [soleil,iris], [pluie,iris], [pluie, pin], [soleil,cerisier], [oiseau,cerisier], [soleil,pin], [oiseau,iris], [tanzaku,cerisier], [tanzaku,erable]]).


/* Affichage du plateau */
ecrire(oiseau):-write('o').
ecrire(tanzaku):-write('t').
ecrire(soleil):-write('s').
ecrire(pluie):-write('p').
ecrire(erable):-write('e').
ecrire(iris):-write('i').
ecrire(cerisier):-write('c').
ecrire(pin):-write('p').

/* deux fact pour bien afficher les joueurs*/
ecrire_tuile(j1):-write('J1').
ecrire_tuile(j2):-write('J2').
ecrire_tuile([T|[]]):-ecrire(T),!.
ecrire_tuile([T|Q]):-ecrire(T), ecrire_tuile(Q).

ecrire_tuiles([T|[]]):-ecrire_tuile(T),!.
ecrire_tuiles([T|Q]):-ecrire_tuile(T), write(' | '), ecrire_tuiles(Q).

affiche_ligne([T|[]]):-ecrire_tuiles(T),!.
affiche_ligne([T|Q]):-ecrire_tuiles(T),nl, write('-----------------'), nl, affiche_ligne(Q).

/*  Afficher le plateau */
affiche_plateau(L):-affiche_ligne(L),nl,nl,nl.


/* Generation du plateau (sous forme de listes imbriquées) */
/* selectionner par hazard un tuile de la liste Tuile et l'ajouter dans la ligneRetourner*/
ajouter_element(ListeTuiles, LigneActuelle, 1, NouvListeTuiles, LigneARetourner):-
	length(ListeTuiles, MAX),
	MAX1 is MAX + 1,
	random(1, MAX1, I),
	nth(I, ListeTuiles, E),
	delete(ListeTuiles, E, NouvListeTuiles),
	LigneARetourner = [E|LigneActuelle],!.
ajouter_element(ListeTuiles, LigneActuelle, J, NouvListeTuiles, LigneARetourner):-
	length(ListeTuiles, MAX),
	MAX1 is MAX + 1,
	random(1, MAX1, I),
	nth(I, ListeTuiles, E),
	delete(ListeTuiles, E, NouvListeTuilesInterm),
	NouvLigneActuelle = [E|LigneActuelle],
	NouvJ is J-1,
	ajouter_element(NouvListeTuilesInterm, NouvLigneActuelle, NouvJ, NouvListeTuiles, LigneARetourner).

/*  Generer par hazard une ligne (4 tuiles) de tuile*/	
nouvelle_ligne(ListeTuiles, NouvListeTuiles, LigneARetourner):-ajouter_element(ListeTuiles, [], 4, NouvListeTuiles, LigneARetourner).

/* Generer Nlignes de tuile*/
generer_lignes_plateau(ListeTuiles, 1, NouvListeTuiles, PlateauFinal):-
	nouvelle_ligne(ListeTuiles, NouvListeTuiles, NouvelleLigne),
	PlateauFinal = [NouvelleLigne],!.
generer_lignes_plateau(ListeTuiles, NLignes, NouvListeTuiles, PlateauFinal):-
	NewNLignes is NLignes-1,
	generer_lignes_plateau(ListeTuiles, NewNLignes, NouvListeTuilesInterm, PlateauFinalInterm),
	nouvelle_ligne(NouvListeTuilesInterm, NouvListeTuiles, NouvelleLigne),
	PlateauFinal = [NouvelleLigne|PlateauFinalInterm].

/*  Generer par hazard un plateau de 4*4 */
plateau_depart(PlateauFinal):-tuiles(ListeTuiles), generer_lignes_plateau(ListeTuiles, 4, _, PlateauFinal).


/* tester si un tuile est dans le plateau */
in_ligne([T|_],T).
in_ligne([_|Q],Tuile):-in_ligne(Q,Tuile).

in_plateau([T|_],Tuile):-in_ligne(T,Tuile).
in_plateau([_|Q],Tuile):-in_plateau(Q,Tuile).

%correction : coup_possible(+Plateau, +Tuile, +Coup).
coup_possible(Plateau,[],[_,T]):-in_plateau(Plateau,T).
coup_possible(Plateau,[T1,_],[_,[T1,Y]]):-in_plateau(Plateau,[T1,Y]).
coup_possible(Plateau,[_,T2],[_,[X,T2]]):-in_plateau(Plateau,[X,T2]).

/* tester si joueur est gagné en ligne */
reussi_ligne(Joueur,[T|_]):-en_ligne(Joueur,T),!.
reussi_ligne(Joueur,[_|Q]):-reussi_ligne(Joueur,Q).
en_ligne(Joueur,[T|[]]):-T=Joueur,!.
en_ligne(Joueur,[T|Q]):- T=Joueur,en_ligne(Joueur,Q).

/* tester si joueur est gagné en diagonale */
reussi_diagonale(Joueur,[[Joueur|_],[_,Joueur|_],[_,_,Joueur,_],[_,_,_,Joueur]]):-!.
reussi_diagonale(Joueur,[[_,_,_,Joueur],[_,_,Joueur,_],[_,Joueur|_],[Joueur|_]]).

/*
reussi_colonne(Joueur,[[Joueur|_],[Joueur|_],[Joueur|_],[Joueur|_]]):-!.
reussi_colonne(Joueur,[[_,Joueur|_],[_,Joueur|_],[_,Joueur|_],[_,Joueur|_]]):-!.
reussi_colonne(Joueur,[[_,_,Joueur,_],[_,_,Joueur,_],[_,_,Joueur,_],[_,_,Joueur,_]]):-!.
reussi_colonne(Joueur,[[_,_,_,Joueur],[_,_,_,Joueur],[_,_,_,Joueur],[_,_,_,Joueur]]).
*/
/* tester si joueur est gagné en colonne */
reussi_colonne(Joueur,Plateau):-colones(Plateau,Cs),reussi_ligne(Joueur,Cs).

/* tester si joueur est gagné en carre */
en_carre(Joueur,[T1|[TT1|_]],[T2|[TT2|_]]):-T1==Joueur,TT1==Joueur,T2==Joueur,TT2==Joueur,!.
en_carre(Joueur,[_|[TT1|Q1]],[_|[TT2|Q2]]):-en_carre(Joueur,[TT1|Q1],[TT2|Q2]).
reussi_carre(Joueur,[L1,L2,_,_]):-en_carre(Joueur,L1,L2),!.
reussi_carre(Joueur,[_,L2,L3,_]):-en_carre(Joueur,L2,L3),!.
reussi_carre(Joueur,[_,_,L3,L4]):-en_carre(Joueur,L3,L4).

/* verifier que si les tuiles de joueur sont placés dans en ligne, en colonne, etc */
gagne(Joueur, Plateau):-reussi_carre(Joueur, Plateau).
gagne(Joueur, Plateau):-reussi_ligne(Joueur, Plateau).
gagne(Joueur, Plateau):-reussi_colonne(Joueur, Plateau).
gagne(Joueur, Plateau):-reussi_diagonale(Joueur, Plateau).

/* verifier que s'il existe des tuile le joueur peut jouer*/
bloque(_, Tuile, Plateau):- \+setof(X,coup_possible(Plateau,Tuile,[_,X]),_).
%bloque est vrai aussi si findall coup_possible ne renvoie rien.

/* verifier que si joueur est gagné ou pas*/
victoire(Joueur, Tuile, Plateau):-bloque(Joueur, Tuile, Plateau).
victoire(Joueur, _, Plateau):-gagne(Joueur, Plateau).


%jouer_coup(+PlateauInitial, +Coup, ?NouveauPlateau)
remp_ligne([T1|Q1],Tuile,Joueur,NouvelleLigne):-T1=Tuile,!,concat([Joueur],Q1,NouvelleLigne).
remp_ligne([T1|Q1],Tuile,Joueur,[T2|Q2]):-T2=T1,remp_ligne(Q1,Tuile,Joueur,Q2).
remp_plateau([T1|Q1],Tuile,Joueur,NouveauPlateau):-remp_ligne(T1,Tuile,Joueur,NouvelleLigne),!,concat([NouvelleLigne],Q1,NouveauPlateau).
remp_plateau([T1|Q1],Tuile,Joueur,[T2|Q2]):-T2=T1,remp_plateau(Q1,Tuile,Joueur,Q2).

/* jouer un coup dans le plateau */
%jouer_coup(+Plateau,+Coup,?NouveauPlateau)
jouer_coup(Plateau,[Joueur,Tuile],NouveauPlateau):-
	remp_plateau(Plateau,Tuile,Joueur,NouveauPlateau).

/*  Changer le joueur ver adversaire */
change_joueur(j1,j2).
change_joueur(j2,j1).

/*  Boucle de jeu humain vs humain commence*/
boucle_jeu(Plateau, Joueur, Vainqueur,TuilePrecedente):-
	affiche_plateau(Plateau),
	write('C''est au tour du joueur '),write(Joueur),write(' de jouer :'),nl,
	read(Tuile),
	Coup = [Joueur,Tuile],
	(
	coup_possible(Plateau,TuilePrecedente,Coup)->
		jouer_coup(Plateau, Coup, NouveauPlateau),
		(
			victoire(Joueur, Tuile, NouveauPlateau)->
				Vainqueur = Joueur,
				affiche_plateau(NouveauPlateau)
			;
				change_joueur(Joueur, NouveauJoueur),
				boucle_jeu(NouveauPlateau, NouveauJoueur, Vainqueur,Tuile)
		)
	;
		nl,write('Tuile incorrecte'),nl,nl,
		boucle_jeu(Plateau, Joueur, Vainqueur,TuilePrecedente)
	).

humainhumain(Vainqueur):-
plateau_depart(Plateau),
boucle_jeu(Plateau, j1, Vainqueur,[]),
write('Le vainqueur est : '), write(Vainqueur),!.