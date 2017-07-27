#!/bin/sh
#!/bin/bash
#!/bin/ipython
#This shell script is used to run MadGraph 5 commands and events:
#==========================Setting the directory of MadGraph 5=========================#

echo -e "\e[1;34m Welcome to MadShell! By Thomas Nommensen\e[0m"
#Finding the directories which have MadGraph 5
MadGraph=($(find ~/ -name "mg5_aMC" ))

#Waiting for user input which directory is correct
echo "Please select MadGraph 5 directory:"
select dir in "${MadGraph[@]}";
do
	[ -n "${dir}" ] && break
done

#Extract the directory and change to it!
directory="$(dirname $dir)/"
cd $directory

#Removing any existing files
rm -r */
#============We now generate the config file for MadGraph 5:======================#
echo "Entering Configuration Mode:"

#_____________Generating arrays containing processes_____________
# the variables "i" and "t" are temp variables and will be cleared after each section
continue="no"
while [ "no" == $continue ];
do
	#_____________Process to run__________________________________#
	read -p "Enter the processes to be generated (ending with ';'): " input
	splitter=($(echo $input | fold -w1))
	generate=()
	for i in ${splitter[@]};
	do 	
		if [[ "$i" = ";" ]];
		then				
			generate+=("$t") 
			t=""
		else	
			t="$t$i"
		fi
	done 
	echo "${generate[@]}"
	
	unset i #Clearing variable
	unset t	#Clearing variable 
	unset splitter
	
	#__________This is to get the names in code of the entered process___________#
	splitter=($(echo $input | sed -e "s/;/#/g" | sed -e "s/ /!/g" | fold -w1))
	coding=()
	for i in ${splitter[@]};
	do 	
		if [[ "$i" = "#" ]];
		then				
			coding+=("$t") 
			t=""
		else	
			t="$t$i"
		fi
	done 	
	unset i #Clearing variable
	unset t	#Clearing variable 
	unset splitter
	
	#_____________Giving names to each run___________________________
	read -p "Enter the name of output (ending with ';'): " names
	splitter=($(echo $names | fold -w1))
	Names=()
	for i in ${splitter[@]};
	do 	
		if [[ "$i" = ";" ]];
		then				
			Names+=("$t") 
			t=""
		else	
			t="$t$i"
		fi
	done 
	echo "${Names[@]}"
	
	unset i #Clearing variable
	unset t	#Clearing variable 
	unset splitter

	#This will ensure that for each process there is a name present
	if [[ ${#Names[@]} == ${#generate[@]} ]]; then
		echo -e "\e[1;32m You are ready to continue! \e[0m"
		continue="yes"
	else 
		echo -e "\e[1;31m Please give for each process a name! \e[0m"
	fi	
done
generate+=("Finished")
#==========Menu for adding in subprocesses=============# 
read -p "Would you like to add a sub process? (y/n) " answer
if [[ "$answer" == "y" ]]; 
then 
	echo "Please select one of the following:"
	continue="false"
	while [[ "$continue" == "false" ]]; do
		select add in "${generate[@]}";
		do
				[ -n ${add} ] && break
		done
		#__________________Exiting___________________________________________#
		if [[ "$add" == "Finished" ]];
		then
			for i in "${!generate[@]}";
			do
				if [[ "${generate[$i]}" == "Finished" ]]; 
				then
					continue	
				else
					NameOfOutput=${Names[$i]}
					#__________This is to make sure there is a MadShell File____#
					place="$(dirname $dir)/$NameOfOutput.MadShell"
					if [[ -f "$place" ]];
					then
						cat $place >> MadShell #<---- if the file is there continue 
						echo "exit" >> MadShell
						rm $place
					else				
						front="generate ${coding[$i]}"
						echo  $front | tr "!" " ">>$NameOfOutput.MadShell
						NameOfOutput=${Names[$i]}
						echo "output $NameOfOutput">>$NameOfOutput.MadShell 
						cat $place >> MadShell
						echo "exit" >> MadShell
						rm $place
					fi
				fi	
			done
			continue="true"
			continue
		else
			#_______________Finding index of add in generate____________________#
			for i in "${!generate[@]}";
			do
				if [[ "${generate[$i]}" == "${add}" ]];
				then
					front=${coding[$i]}
					NameOfOutput=${Names[$i]}
				fi
			done
			echo "You have selected $add"	
			read -p "Enter the subprocess to be added (ending with ';'): " Subinput
			#______________Storing and Confirming________________________#
			subcode=($(echo $Subinput | sed -e "s/;/#/g" | sed -e "s/ /!/g" | fold -w1))
			subprocess=()
			for decode in ${subcode[@]};
			do 	
				if [[ "$decode" = "#" ]];
				then				
					subprocess+=("$temp") 
					temp=""
				else	
					temp="$temp$decode"
				fi
			done 
			Message="You have added: \e[1;32m${subprocess[@]}\e[0m to $add"
			echo -e ${Message[@]} | tr "!" " " 
			unset decode 	#Clearing variable
			unset Subinput	#Clearing variable 
			unset subcode	#Clearing variable
			unset temp	#Clearing variable
			unset Message	#Clearing variable
		
			#=======Generating the MadShell config===================#
			place="$(dirname $dir)/$NameOfOutput.MadShell"
			if [[ -f "$place" ]];
			then
				rm $NameOfOutput.MadShell #This removes existing file 
				MG5Gen="generate $front" #This is the instruction to generate process.
				echo $MG5Gen | tr "!" " ">>$NameOfOutput.MadShell #Creates the file
				for subcode in "${subprocess[@]}";
				do
					Message="add process $subcode"
					echo $Message | tr "!" " ">>$NameOfOutput.MadShell    #Creates the file
				done
				echo "output $NameOfOutput">>$NameOfOutput.MadShell        #Creates the file 				
			else
				MG5Gen="generate $front" #This is the instruction to generate process.
				echo $MG5Gen | tr "!" " ">>$NameOfOutput.MadShell #Creates the file
				for subcode in "${subprocess[@]}";
				do
					Message="add process $subcode"
					echo $Message | tr "!" " ">>$NameOfOutput.MadShell    #Creates the file
				done
				echo "output $NameOfOutput">>$NameOfOutput.MadShell        #Creates the file 
			fi
		fi
	done
elif [[ "$answer" == "n" ]];
then
	for i in "${!generate[@]}";
	do
		if [[ "${generate[$i]}" == "Finished" ]]; 
		then
			continue	
		else 
			front="generate ${coding[$i]}"
			echo  $front | tr "!" " ">>MadShell
			NameOfOutput=${Names[$i]}
			echo "output $NameOfOutput">>MadShell
			echo "exit" >> MadShell
		fi
	done
fi
#============= Actually creating Directories ===================#
echo "Generating the Files and directories!"
python mg5_aMC MadShell > /dev/null 2>&1
rm MadShell

#=======================removing variables=======================# 
unset name
unset del
unset delimit
unset answer 
unset MG5Gen
unset subcode
unset NameOfOutput
unset front
unset Message
unset i 

########################################################################################
########################################################################################
#############				################################################
#############	 Useful variables	################################################
#############				################################################
#======================================================================================#
# $directory = MadGraph5 bin directory   					       #
# ${generate[@]} = The entered Processes in string form with no whitespace!            #
# ${Names[@]} = This gives the process names    				       #
# ${coding[@]} = The generate string parsed using a code # = new element != Space      #
# ${subprocess[@]} = Added extra processes in code 				       #
#======================================================================================#
########################################################################################
########################################################################################

#================Entering the options menu for tweaking============================#
#==================================================================================#
#Declaring variables
Pythia=()
Evnts=()
BeamEV1=()
BeamEV2=()
NumberOfRuns=1
#Standard Settings for MadGraph5 
Import_model="!" 
Pythia="no"
SimDetector="Off"
Weight="no"
MadSpin="no"
extraction="no"
Analysis="Off"


#Adding a finish option to menu
selections=("Pythia/Detector" "Edit Number of Events" "Edit Beam Energy" "Model to Import" "Number of Runs" "Les Houches Format" "Plots" "Finished")

#User interaction point
read -p "Would you like to edit these processes? (y/n): " options
if [ "$options" == "y" ];
then 
	#This level enables user to chose the process to edit 
	running="false" #Keeping the loop running for the options menu
	while [ "$running" == "false" ]; 
	do 
		#Submenu with selections options 
		suboptions="incomplete"
		echo "Chose the process which you would like to edit: "
		select process in "${generate[@]}";
		do
			[ -n "${process}" ] && break
		done
		if [ "$process" == "Finished" ]; 
		then 	
			for name in "${Names[@]}";
			do			
				place=$directory$name/Cards/MadShell
				Extract=$directory$name/Cards/Extract
				Plotting=$directory$name/Cards/Plotting	
				if [[ -f "$place" ]];			
				then			
					continue
				else	
					cd $directory$name/Cards/				
					second="launch $name"	      #Launches the output name generated from the start
					echo "$second" >> MadShell
					echo "done" >> MadShell
					echo "done" >> MadShell
					echo "no" >> Extract
					cd $directory
				fi

				if [[ -f "$Extract" ]];			
				then			
					continue
				else	
					cd $directory$name/Cards/				
					echo "no" >> Extract
					cd $directory
				fi

				if [[ -f "$Plotting" ]];			
				then			
					continue
				else	
					cd $directory$name/Cards/				
					echo "no" >> Plotting
					cd $directory
				fi
				
			done	
			unset Evnts
			unset BeamEV1
			unset BeamEV2
			unset NumberOfRuns
			running="true" && break	
		fi

		#Searching the generate array for index of process selected 
		for i in "${!generate[@]}";
		do 
			if [[ "${generate[$i]}" = "${process}" ]]; 	
			then
				Name=${Names[$i]}
			fi
		done	

		#Changing to the run_card.dat file directory				
		Wanted="$directory$Name"
		cd "$Wanted"
		File=$(find . -name "run_card.dat" )
		cd "$(dirname $File)/"

		echo "Chose one of the options below"
		while [ "$suboptions" == "incomplete" ];
		do
			echo -e "You have chosen; Process: \e[1;32m"$process"\e[0m" "Name: \e[1;32m"$Name"\e[0m" ", Number of Events: \e[1;32m"$Evnts"\e[0m, Beam Energy, 1: \e[1;32m"$BeamEV1"\e[0m 2: \e[1;32m"$BeamEV2"\e[0m, Model: \e[1;32m"$Import_model"\e[0m, Number of Runs: \e[1;32m"$NumberOfRuns"\e[0m""\e[0m, Les Houches Format extraction: \e[1;32m"$extraction"\e[0m ,  Plotting: \e[1;32m"$Plot"\e[0m"  
			select category in "${selections[@]}";
			do
				[ -n "${category}" ] && break
			
			done 
			#====================Exits the submenu====================#
			if [ "$category" == "Finished" ];
			then
				#Writing a config file for MadGraph5 for these particular settings
				#Used Variables: Pythia, SimDetector, MadSpin, Weight, Import_model , NumberOfRuns, Name
				rm MadShell > /dev/null 2>&1 #This removes any existing MadShell settings file.
				rm Extract > /dev/null 2>&1
				rm Plotting > /dev/null 2>&1
				for (( i=1; i <= $NumberOfRuns; i++))
				do 	
					if [[ "$i" == "1" ]];
					then
						if [[ "$Import_model" == "!" ]]; then
							Nothing=""
						else
							first="import $Import_model" #Imports models
							echo "$first" >> MadShell     
						fi
					fi

					second="launch $Name"	      #Launches the output name generated from the start
					echo "$second" >> MadShell
					
					if [[ "$i" == "1" ]];
					then

						if [[ "$Pythia" == "yes" ]]; then
							if [[ "$SimDetector" == "PGS" ]]; then 
								echo "2" >> MadShell
							elif [[ "$SimDetector" == "Delphes" ]]; then
								echo "2" >> MadShell
								echo "2" >> MadShell
							elif [[ "$SimDetector" == "Off" ]]; then
								echo "1" >> MadShell
							fi
						fi	
				
						if [[ "$MadSpin" == "yes" ]]; then
							echo "4" >> MadShell
						fi
		
						if [[ "$Weight" == "yes" ]]; then
							echo "5" >> MadShell				
						fi
						if [[ "$Analysis" == "ExROOT" ]]; then
							echo "3" >> MadShell
						fi
						if [[ "$Analysis" == "Off" ]]; then
							echo "3" >> MadShell
							echo "3" >> MadShell
						fi
					fi
					echo "done" >> MadShell
					echo "done" >> MadShell
					echo "$extraction" >> Extract
					echo "$Plot" >> Plotting
				done
				echo "exit" >> MadShell
				unset Pythia
				unset MadSpin
				unset Weight
				unset Import_model
				unset SimDetector
				NumberOfRuns=1

				#Standard Settings for MadGraph5 
				Import_model="!" 
				Pythia="no"
				SimDetector="Off"
				Weight="no"
				MadSpin="no"
				suboptions="complete"
				extraction="no"
				Plot="no"
			
			#Enters Pythia/Detector settings
			elif [ "$category" == "Pythia/Detector" ];
			then 	
				Launching=("Shower/Hadronization" "Detector Simulation" "Analysis" "Decay with MadSpin" "Add weights to events for different model hypothesis" "Back")
				PythiaDetector="True"
				while [[ "$PythiaDetector" == "True" ]]; 
				do
					select Sim in "${Launching[@]}";
					do
						[ -n "${Sim}" ] && break
					done 		
					if [[ "$Sim" == "Shower/Hadronization" ]];
					then 
						read -p "Enable Showering/Hadronization using Pythia6? (y/n) " SimPy
						if [[ "$SimPy" == "y" ]]; then
							Pythia="yes"
						elif [[ "$SimPy" == "n" ]]; then
							Pythia="no"
						fi
					elif [[ "$Sim" == "Detector Simulation" ]];
					then 
						echo "By enabling detector simulations you also activate Pythia!"
						Detec=("PGS" "Delphes" "Off")
						select DetecSim in "${Detec[@]}";
						do
							[ -n "${DetecSim}" ] && break
						done 		
						if [[ "$DetecSim" == "PGS" ]]; then
							Pythia="yes"
							SimDetector="PGS"
						elif [[ "$DetecSim" == "Off" ]]; then
							Pythia="no"
						elif [[ "$DetecSim" == "Delphes" ]]; then
							Pythia="yes"
							SimDetector="Delphes"
						fi
					elif [[ "$Sim" == "Decay with MadSpin" ]];
					then 
						read -p "Decay with MadSpin? (y/n) " MadAns
						if [[ "$MadAns" == "y" ]]; then
							MadSpin="yes"
						elif [[ "$MadAns" == "n" ]]; then
							MadSpin="no"
						fi
	
					elif [[ "$Sim" == "Add weights to events for different model hypothesis" ]];
					then 
						read -p "Add Weights? (y/n) " WeighANS
						if [[ "$WeighANS" == "y" ]]; then
							Weight="yes"
						elif [[ "$WeighANS" == "n" ]]; then
							Weight="no"
						fi

					elif [[ "$Sim" == "Analysis" ]];
					then 
						echo "Select an analysis package on the events generated:"
						Package=("MadAnalysis 5" "ExRootAnalysis" "Off")
						select Analys in "${Package[@]}";
						do 
							[ -n "${Analys}" ] && break
						done 
						if [[ "$Analys" == "MadAnalysis 5" ]];
						then 
							Analysis="MadAnalysis"
						elif [[ "$Analys" == "ExRootAnalysis" ]];
						then 
							Analysis="ExROOT"
						elif [[ "$Analys" == "Off" ]];
						then 
							Analysis="Off"
						fi

					elif [[ "$Sim" == "Back" ]];
					then
						echo "Weight: $Weight MadSpin: $MadSpin Detector: $SimDetector Pythia: $Pythia Analysis: $Analysis"
						sleep 2
						PythiaDetector="false"
					fi
				done

			#Enters Number of Events 
			elif [ "$category" == "Edit Number of Events" ];
			then 		
				unset i
				unset Card	

				#Changing the settings in the .dat file using the sed -i (interactive command)				
				Card=run_card.dat
				read -p "Enter the number of events which are to be generated: " Evnts
				sed -i "/nevents/c\ "$Evnts" = nevents ! Number of unweighted events requested" $Card

			#Enters Edit Beam Energy
			elif [ "$category" == "Edit Beam Energy" ];
			then 
				unset i		#Cleaning Variables 
				unset Card
				unset Name
				unset Wanted

				BeamLOOP="true"
				Beams=("Beam1" "Beam2" "Finished")
				
				#=============Adding Beam menu====================#
				while [[ "$BeamLOOP" == "true" ]]; 
				do
					select object in "${Beams[@]}";
					do
						[ -n "${object}" ] && break
					done

					if [[ "$object" == "Finished" ]];
					then
						BeamLOOP="false" 	#Breaking the loop conditions return to previous 
					#============Beam 1==============
					elif [[ "$object" == "Beam1" ]];
					then
						unset i
						unset Card
	
						#Changing the settings in the .dat file using the sed -i (interactive command)				
						Card=run_card.dat
						read -p "Enter the energy of Beam 1 (GeV): " BeamEV1
						sed -i "/ebeam1/c\     "$BeamEV1"     = ebeam1  ! beam 1 total energy in GeV" $Card
					#===========Beam 2===============
					elif [[ "$object" == "Beam2" ]];
					then 

						unset i
						unset Card
						unset Name
						unset Wanted	
	
						#Changing the settings in the .dat file using the sed -i (interactive command)				
						Card=run_card.dat
						read -p "Enter the energy of Beam 2 (GeV): " BeamEV2
						sed -i "/ebeam2/c\     "$BeamEV2"     = ebeam2  ! beam 2 total energy in GeV" $Card
					fi
				done
			#Enters Model to Import
			elif [ "$category" == "Model to Import" ];
			then 
				echo "!!!!!!!!!!!Make sure you READ MadGraph5 instructions!!!!!!!!!!!!!!!!!!"
				read -p "Please write the model you would like to import (e.g. MSSM...): " Import_model

			#Enters Number of Runs 
			elif [ "$category" == "Number of Runs" ];
			then 
				read -p "How many runs would you like to conduct? " NumberOfRuns
		
			#Extraction of LHE files in the run folders
			elif [ "$category" == "Les Houches Format" ];
			then 
				read -p "Would you like to extract the .lhe files in the run folders? (y/n) " extract
				if [ "$extract" == "n" ];
				then
					extraction="no" 
				elif [ "$extract" == "y" ];
				then
					extraction="yes"
				fi

			#Drawing Plots with the root output 
			elif [ "$category" == "Plots" ];
			then 
				echo -e  "(\e[1;31mThis will enable Pythia and Delphes!\e[0m)"
				read -p "Would you like to produce a histogram of the Delphes output? (y/n) " Plotting
				if [ "$Plotting" == "n" ];
				then
					Plot="no"
				elif [ "$Plotting" == "y" ];
				then
					Plot="yes"
					Pythia="yes"
					SimDetector="Delphes"
				fi
			fi
		done

	done
elif [[ "$options" == "n" ]]; then 
	cd $directory
	for name in "${Names[@]}";
	do			
		second="launch $name"  #Launches the output name generated from the start
		echo "$second" >> MadShell
		echo "done" >> MadShell
		echo "done" >> MadShell
	done	
	python mg5_aMC MadShell > /dev/null 2>&1
	rm MadShell	
fi 

#This will be the method used to execute the saved MadShell file for each directory in names 
if [[ "$options" == "y" ]];
then 
	#Finding the number of MadShell Files
	cd $directory
	File=($(find $directory -name "MadShell" )) #<----- MadShell for initial run
	Ext=($(find $directory -name "Extract" )) #<----Extraction file
	Plo=($(find $directory -name "Plotting" )) #<----- Plotting File
	Temp="$(dirname ${File[$total]})/MadShell_temp" #<------- Temp File will be removed
	MadShellRun="$(dirname ${File[$total]})/MadShellRun" #<---- Remaining run MadShell
	#______Collects number of total runs and shortens the MadShell file__________#
	for total in "${!File[@]}";
	do
		MadShell=${File[$total]}
		LesExt=${Ext[$total]}
		n=($(grep -o "launch" $MadShell | wc -l)) #<----collects the number of runs
		TotalRuns+=("$n")  

		#==== This section filters settings out of the MadShell File =====# 
		cat $MadShell | while read line 
		do 			
			if [[ $t -le 1 ]];
			then
				if  [[ "$line" == "done"* ]];
				then
					t=$((t+1))	
				fi
				echo "$line" >> $Temp
			fi
		done
		t=0
		echo "exit" >> $Temp
		rm $MadShell 
		mv $Temp $MadShell #<---------- Recreates and renames the existing file for the first run!
		#=================End===============================================#
	done

	#The execution loop!!!!
	for i in "${!File[@]}";
	do 
		#===============This is to solve the misname bug========
		for find in "${!File[@]}"; 
		do 
			if [[ "${File[$i]}" == *"${Names[$find]}"* ]];
			then 
				newname=${Names[$find]}
			fi

		done
		#========= $newname is the actual runs name ============
		echo "Starting runs in $newname"

		######################Creating the MadShellRun##################################
		echo "launch $newname" >> $MadShellRun
		echo "done" >> $MadShellRun
		echo "done" >> $MadShellRun
		echo "exit" >> $MadShellRun
		################################################################################

		number=${TotalRuns[$i]}
		echo "Total Runs for this session: $number"
		for (( x=1; x <= $number; x++));
		do
			#This executes the loops
			path=${File[$i]}
			MadRun="$(dirname $path)/MadShellRun"
			
			if [[ $x -le 1 ]];
			then
				python mg5_aMC "$path" > /dev/null 2>&1 #<<<<<<< initial run for post launch settings 
			elif [[ $x -gt 1 ]];
			then
				python mg5_aMC "$MadRun" > /dev/null 2>&1	#<<<<<<<< Post runs 
			fi	

			#This is for the progress bar!!!##########
			unset exact
			unset prop
			percent=$((x*100 / number))			
			per=$((percent/5))
			for (( progress=0; progress <= $per; progress++));
			do 
				increment="="
				prop="$increment$prop"
				exact="$prop>"	
			done
			echo -ne "progress: $exact $percent % \r"
		done
		#This is the Total runs collected!!!
		echo "completed $number runs for $newname"
		echo "Time: $(date)"
		
		#=====================Using ReadingEvents.py==========================#
		Les=${Ext[$i]}
		decision=($(grep -o "no" $Les | wc -l))
		if [[ "$decision" == "1" ]]; 
		then
			echo "No extraction performed"
		elif [[ "$decision" == "0" ]];
		then 
			echo "Extracting Les Houches Format"
			for (( y=1; y <= $number; y++ )); 
			do	
				if [[ $y -lt 10 ]];
				then
					t="$directory$newname/Events/run_0$y/unweighted_events.lhe.gz"
					z="$directory$newname/Events/run_0$y/unweighted_events.gz"
					mv $t $z
					gzip -d "$z" 
					Reading="$directory$newname/Events/run_0$y/unweighted_events"
				elif [[ $y -ge 10 ]];
				then
					t="$directory$newname/Events/run_$y/unweighted_events.lhe.gz"
					z="$directory$newname/Events/run_$y/unweighted_events.gz"	
					Reading="$directory$newname/Events/run_$y/unweighted_events"
					mv $t $z
					gzip -d "$z" 
				fi
				echo " Reading directory: $Reading"
				ReadingDirec=$(find ~/ -name "ReadingEvents.py" )
				python "$ReadingDirec" "$Reading"
			done
		fi	
		#===================================================================#

		#============Using DelphesReader.py=================================#
		echo "Performing plots"
		Plots=${Plo[$i]}
		PlotDecision=($(grep -o "no" $Plots | wc -l))
		if [[ "$PlotDecision" == "1" ]]; 
		then
			echo "Not plotting Delphes root"
		elif [[ "$PlotDecision" == "0" ]];
		then 
			for (( y=1; y <= $number; y++ )); 
			do	
				if [[ $y -lt 10 ]];
				then
					Reading="$directory$newname/Events/run_0$y/tag_1_delphes_events.root"
				elif [[ $y -ge 10 ]];
				then	
					Reading="$directory$newname/Events/run_$y/tag_1_delphes_events.root"
				fi
				ReadingDirec=$(find ~/ -name "DelphesReader.py" )
				python "$ReadingDirec" "$Reading"
			done
		fi	
		#===================================================================#
		#Clean Up
		rm $path
		rm $Les
		rm $Plots
		rm $MadRun
	done
fi