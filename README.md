# merging-simulation
todo:
1) spiegare perchè con più macchine non funziona (problema nell'associazione)
2) studiare come cambia la velocità media delle macchine sulla corsia principale sia senza macchine che fanno merging che con un numero diverso di macchine che fa merging
3) fare grafici sulla velocità media
4) spiegare quali problemi ho riscontrato, come li ho risolti e perchè


problemi affrontati e risolti.
1) In un primo approccio i veicoli partivano tutti vicini senza garanzia della distanza di sicurezza deltax ma questo creava troppi problemi.
Faceva si che in molte situazioni invece di moderare la velocità per garantire la distanza di sicurezza interveicolo avesse priorità la moderazione della vvelocità in relazione a quella de veicolo associato andando a rompere le regole di tracking stabilite.
soluzione: far partire le macchine già distanziate. conseguenza: numero massimo di macchine 8 sopra e 3 sotto.
2) l'algoritmo di merging per come è fatto (con accelerazione) portava sempre le macchine a raggiungere la massima velocità quindi arrivati ad un certo punto non essa poteva più aumentare con conseguente rottura dell'algoritmo.
soluzione: invece di far acellerare faccio decellerare. (fai nuovo schema)


c'è un problema quando due agenti si associano alla stessa macchina, in quel caso l'algoritmo di tracking non è mantenuto