/**
* Name: mstp2PAZIMNASolibia
* Author: basile
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model mstp2PAZIMNASolibia

global {
	/** Insert the global definitions, variables and actions here */
	int Nbre_De_Nid <- 1 parameter: "Nbre de nid";
	int Nbre_de_Nouriture <- 5 parameter: "Nbre nourriture";	
	int Nbre_de_Fourmis <- 30 parameter: "Nbre fourmi";	
	int Dure_de_marque <- 30 parameter: "Nbre marque";	
	
	init {
		create Nid number: Nbre_De_Nid{	}
		create Nouriture number: Nbre_de_Nouriture{}
		create Fourmi number: Nbre_de_Fourmis{
			set home <- one_of(Nid); 
			set location <- home.location;
			//set curent_nouriture <- one_of(Nour); 
		}
	}	
}

species Nouriture{
	point position init:[rnd(100-4*size)+size,rnd(100-4*size)+size];
	rgb couleur <-  #red;
	float size <- 2.0;
	float quantity <- rnd(15) ;
	
	aspect basic {
		draw circle(size) color:couleur;
	}
}

species Nid{
	point position init:[rnd(100-4*size)+size,rnd(100-4*size)+size];
	rgb couleur <-  #green;
	float size <- 5.0;
	
	aspect basic {
		draw circle(size) color:couleur;
	}
}

species Marque{
	point position; // init:[rnd(100-4*size)+size,rnd(100-4*size)+size];
	rgb couleur <-  #black; //rnd_color(255);
	float size <- 1.5;
	int duration <- Dure_de_marque;
	int count <- duration; 
	Nouriture data;
	
	reflex mis_a_jour_duree {
		count <- count -1;
		if(count<=0){
			do die;
		}
	}
	aspect basic {
		draw square(size) color:couleur;
	}	
}

//species Fourmi skills:[moving]
species  Fourmi skills:[moving]{
	point position; // init:[rnd(100-4*size)+size,rnd(100-4*size)+size];
	rgb couleur <-  #blue; //rnd_color(255);
	float size <- 1.0;
	float speed <- rnd(20)+1.0;
	float charge <- rnd(10); // <- 
	float observation_range <- size/2; //Dure_de_marque;
	Nid home;
	list listNouriture;
	Nouriture curent_nouriture <- nil;
	float creation_marque_duration <- rnd(speed);
	float count_creation <- creation_marque_duration;
	bool encharge <- false; //Vide : true = chargé
	
	reflex deplacement_hazard when: curent_nouriture=nil {
		//write "En deplacement";
		do action: wander amplitude: 180;
		listNouriture <- list (Nouriture) where (each distance_to self < observation_range);
		if(length(listNouriture)>0){
			curent_nouriture <- first(listNouriture);
			do charger;
			do goto target: home;
		}
		
	}
	
	reflex create_marque when: curent_nouriture!=nil {
		count_creation <- count_creation - 1;
		if(count_creation<=0){
			//Créer une marque
			create Marque number: 1{
				location <- myself.location;
				position <- location;
				data <- myself.curent_nouriture;
			}
		}
	}
	
	/*reflex deplacement_hazard when:curent_nouriture!=nil{
		//Déplaccer au hazard
		//Observer la nouriture + les marques
		let list_marque value: list(Marque)sort_by(self distance_to each);		
		let listNouriture value: list(Nouriture)sort_by(self distance_to each);		
		if(length(list_marque)>0){
			do goto target: first(list_marque);
		}else{
			do goto target: first(list_marque);
			//do goto target: first(list(Marque)sort_by(self distance_to each));
		}
	}*/
	
	reflex amener_nouriture when:curent_nouriture!=nil{
		if(encharge){
			//Décharger s'il est au nid
			let list_nid value: list (Nid) where (each distance_to self < observation_range);
			if(length(list_nid)>0){
				encharge <- false;
			}else{ //aller au nid s'il est loin de nid				
				do goto target: home; //  first (list(Nid)sort_by(self distance_to each));
			}
		}
		if(!encharge){
			//charger s'il est à la nourriture
			//aller au nid s'il est loin de nid
			listNouriture <- list (Nouriture) where (each distance_to self < observation_range);
			if(length(listNouriture)>0){
				curent_nouriture <- first(listNouriture);
				do charger;
				do goto target: home;
			}else{ 	//aller à la nourriture s'il est loin de la nourriture			
				do goto target: first (list(Nouriture)sort_by(self distance_to each));
			}
		}
	}
	
	action charger{
		//diminuer le montant de la nouriture
		write "charger";
		ask curent_nouriture {
			quantity <- quantity - myself.charge;			
			if(quantity  <= 0){
				do die;
			}
		}
		//s'il est à 0 alors nouriture meurt_
		//encharge <- true
		encharge <- true;
	}
	
	aspect basic {
		draw square(size) color:couleur;
	}
}


experiment mstp2PAZIMNASolibia type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display mstp2PAZIMNASolibia {
			species Nid aspect: basic;
			species Fourmi aspect: basic;
			species Nouriture aspect: basic;
			species Marque aspect: basic;			
		}		
	}
}
