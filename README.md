# Collective Rhythms Toolbox 


![crt-logo](https://user-images.githubusercontent.com/1406597/217825450-7ec7e180-1ccf-4fe1-bcf7-6b9250183a41.jpg)


<img width="1300" alt="interface" src="https://user-images.githubusercontent.com/1406597/217840181-bf26a3b2-8121-49c1-9295-4aa0f92c0178.png">



## ABOUT
The "Collective Rhythms Toolbox" (CRT) is a flexible and responsive audio-visual interface for exploring the self-synchronizing behaviors of coupled systems. 
As a class of multi-agent system (MAS), CRT works with networks of coupled oscillators and coupled-metronomes, allowing a user 
to explore different sonification routines that generate emergent rhythms by allowing for real-time parameter modulation. Using groups of coupling matrices, complex coupling topologies allow for a variety of unusual rhythmic states to arise and audio-visual feedback encourages user flow and interactivity. 
Similarly, several real-time analysis techniques provide the user with visual information pertaining to the state of the system in terms of group synchrony. 
As such, different extant techniques used in computer music and contemporary composition can be carried out by parameterizing the system in specific ways 
which are explored from the perspective of dynamical systems based approaches.

CRT is written in Processing and users need the OSCP5 and controlP5 libraries installed as dependencies. 

## Audio Client

The CoupledOscillator.pde and CoupledMetronomes.pde scripts send out OSC messages in the form of audio events. These must be handled by a separate audio client (SuperCollider, Max/MSP, Ableton, etc.) in order to create sound. This repository comes with an example patch in SuperCollider (receive-oscs.scd) that recreates the basic metronome tick/tock sound with the attached woodblock sample. This was done so that users would have more control over the sound events that the dynamical systems generate and allows software more suitable for sound design to handle audio synthesis. 


## EXAMPLES
### Interface Demos
The following videos show several different possibilities and dynamic states possible using the CoupledOscillator models. A user interacts with a separate control window to modify the model parameters in real time. A range of unusual audio-visual rhythmic states can be rendered.  


https://user-images.githubusercontent.com/1406597/217813764-df952f79-7f37-41fb-b522-85a3223bd8d9.mp4


### Simulation of Coupled Metronomes Demo 
The following videos shows the audio-visual output of 100 coupled metronomes. Each metronomes imparts small moments of inertia onto a 'shared platform' and over time the metronomes begin to phase align and synchronize. 


https://user-images.githubusercontent.com/1406597/217811507-f635e668-0785-4fd7-ab4e-998aae70a9d2.mp4


### Simulation of Crowd Applause Demo 

https://user-images.githubusercontent.com/1406597/217825100-1dd00080-81e4-4adc-a72d-358ceaec49ef.mov


# Tutorial 

1. Run the SuperCollider script receive-oscs.scd (NB: you need to boot the server!! (CMD+B). Run the script by placing the cursor inside the code block and press CMD+ENTER) 

2. Open CoupledOscillator.pde

3. Initially, 8 oscillators are in the active in the group. You can add or remove oscillators by pressing '=' or '-' respectively. You can add up to 100 oscillators.  

4. To apply parameters to the entire group, press the button labeled 'GLOBAL_KN' (or press '1') to select all of the oscillators or manually press the all of the corresponding oscillator in the gray matrix of toggle buttons on the left. 

5. Increase coupling by dragging the pink slider labeled KN. You can adjust the natural frequency of the oscillators by adjusting the slider labeled 'FREQ_I'. You won't see the oscillators change into this state yet! 

6. To graft these parameters onto the selected oscillators, press the green button labeled 'SET' (or press 'a' for activate). 

7. With sufficient coupling, the oscillators should begin to phase align and mutually-entrain to the natural frequency you selected in the slider. 

8. You can randomize their initial phases by pressing the button labeled 'RANDOM'. 

9. Press '0' to deselect all of the active oscillators (or manually deselect them in the selection matrix). 

More unusual quasi-periodic/synchronous states arise when you allow individual or groups of oscillators to take on different coupling strengths and natural frequencies. This can be done by just selecting groups of active oscillators from the selector matrix, modifying the coupling strength and natural frequency independently of the others. A number of interesting mode-locking, chimeric, or polyrhythmic states are possible.   





