# Collective Rhythms Toolbox 


![crt-logo](https://user-images.githubusercontent.com/1406597/217825450-7ec7e180-1ccf-4fe1-bcf7-6b9250183a41.jpg)



## ABOUT
The "Collective Rhythms Toolbox" is a flexible and responsive audio-visual interface for exploring the self-synchronizing behaviors of coupled systems. 
As a class of multi-agent system (MAS), The Collective Rhythms Toolbox works with networks of coupled oscillators and coupled-metronomes, allowing a user 
to explore different sonification routines that generate emergent rhythms by allowing for real-time parameter modulation. Using groups of coupling matrices, 
complex coupling topologies allow for a variety of unusual rhythmic states to arise and audio-visual feedback encourages user flow and interactivity. 
Similarly, several real-time analysis techniques provide the user with visual information pertaining to the state of the system in terms of group synchrony. 
As such, different extant techniques used in computer music and contemporary composition can be carried out by parameterizing the system in specific ways 
which are explored from the perspective of dynamical systems based approaches.

CRT is written in Processing and users need the OSCP5 and controlP5 libraries installed as dependencies. 

## Audio Client

The CoupledOscillator.pde and CoupledMetronomes.pde files send out OSC messages in the form of audio events. These must be handled by a separate music software environment in order to create sound. This repository comes with an example patch in SuperCollider (receive-oscs.scd) that recreates the basic metronome tick/tock sound with the attached woodblock sample. This was done so that users would have more control over the sound events that the dynamical systems generate and allows software more suitable for sound design to handle audio synthesis. 


## EXAMPLES
### Interface Demos
The following videos show several different possibilities and dynamic states possible using the CoupledOscillator models. A user interacts with a separate control window to modify the model parameters in real time. A range of unusual audio-visual rhythmic states can be rendered.  


https://user-images.githubusercontent.com/1406597/217813764-df952f79-7f37-41fb-b522-85a3223bd8d9.mp4


### Simulation of Coupled Metronomes Demo 
The following videos shows the audio-visual output of 100 coupled metronomes. Each metronomes imparts small moments of inertia onto a 'shared platform' and over time the metronomes begin to phase align and synchronize. 


https://user-images.githubusercontent.com/1406597/217811507-f635e668-0785-4fd7-ab4e-998aae70a9d2.mp4


### Simulation of Crowd Applause Demo 

https://user-images.githubusercontent.com/1406597/217825100-1dd00080-81e4-4adc-a72d-358ceaec49ef.mov





