/*menu principale*/
/*pour lancer le jeu, tapez 'jeu.' dans la console.*/ 
:-include('basic.pl').
:-include('jeu_ia.pl').
:-include('jeu_humain.pl').

jeu:-logo,repeat,
(menu,read(X),commencer(X)),nl,write('Le jeu est terminé, tapez retour').
commencer(1):-!,humainhumain(_),fail.
commencer(2):-!,humainIA(_),fail.
commencer(3):-!,ia_ia(_),fail.
commencer(4):-!,write('Sortie').
commencer(_):-write('Erreur de saisie'),nl, fail.

logo:-
write('##################################'),nl,
write('#                                #'),nl,
write('#    Bienvenue au jeu de Okiya   #'),nl,
write('#                                #'),nl,
write('#    Réalisé par Martin et Hu    #'),nl,
write('#                                #'),nl,
write('##################################'),nl.

menu:-nl,nl,
write('Choisisez la mode à jouer :'),nl,
write('1 - Human vs Humain'),nl,
write('2 - Humian vs Ordinateur'),nl,
write('3 - Ordinateur vs Ordinateur'),nl,
write('4 - Sortie'),nl.

