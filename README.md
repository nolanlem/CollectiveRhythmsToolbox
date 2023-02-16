# Collective Rhythms Toolbox 


![crt-logo](https://user-images.githubusercontent.com/1406597/217825450-7ec7e180-1ccf-4fe1-bcf7-6b9250183a41.jpg)

# Table of Contents 
1. [About](#about)
2. [Dependencies](#dependencies)
3. [Audio Client](#audio-client) 
4. [Examples](#examples)
5. [About Coupled Oscillator Models](#generative-models)
6. [Keystrokes Guide](#keystrokes)
7. [UI Guide](*ui-guide)

<img width="1300" alt="interface" src="https://user-images.githubusercontent.com/1406597/217840181-bf26a3b2-8121-49c1-9295-4aa0f92c0178.png">



## About <a name ="about"></a>
The "Collective Rhythms Toolbox" (CRT) is a flexible and responsive audio-visual interface for exploring the self-synchronizing behaviors of coupled systems. 
As a class of multi-agent system (MAS), CRT works with networks of coupled oscillators and coupled-metronomes, allowing a user 
to explore different sonification routines that generate emergent rhythms by allowing for real-time parameter modulation. Using groups of coupling matrices, complex coupling topologies allow for a variety of unusual rhythmic states to arise and audio-visual feedback encourages user flow and interactivity. 
Similarly, several real-time analysis techniques provide the user with visual information pertaining to the state of the system in terms of group synchrony. 
As such, different extant techniques used in computer music and contemporary composition can be carried out by parameterizing the system in specific ways 
which are explored from the perspective of dynamical systems based approaches.

## Dependencies <a name ="dependencies"></a>
CRT is written in [Processing](https://processing.org) and requires the [OSCP5](https://sojamo.de/libraries/oscP5/) and [controlP5](https://sojamo.de/libraries/controlP5/) external libraries. 


### Audio Client <a name ="audio-client"></a>

The CoupledOscillator.pde and CoupledMetronomes.pde scripts send out OSC messages in the form of audio events. These must be handled by a separate audio client (SuperCollider, Max/MSP, Ableton, etc.) in order to create sound. This repository comes with an example patch in SuperCollider (receive-oscs.scd) that recreates the basic metronome tick/tock sound with the attached woodblock sample. This was done so that users would have more control over the sound events that the dynamical systems generate and allows software more suitable for sound design to handle audio synthesis. 


## EXAMPLES <a name="examples"></a>
### Interface Demos
The following videos show several different possibilities and dynamic states possible using the CoupledOscillator models. A user interacts with a separate control window to modify the model parameters in real time. A range of unusual audio-visual rhythmic states can be rendered.  


https://user-images.githubusercontent.com/1406597/217813764-df952f79-7f37-41fb-b522-85a3223bd8d9.mp4


### Simulation of Coupled Metronomes Demo 
The following videos shows the audio-visual output of 100 coupled metronomes using a physical model defined by Pantaleone (2002) ("Synchronization of metronomes" doi: 10.1119/1.1501118) [[1]](#1). Each metronomes imparts small moments of inertia onto a 'shared platform' and over time the metronomes begin to phase align and synchronize. This is shown in the following equation of motion:  
<img width="569" alt="coupled-metronome-equations" src="https://user-images.githubusercontent.com/1406597/217867665-1d39b6ea-7252-4463-a53c-167aa67068fb.png">

The first two terms represent the typical pendulum angular acceleration and the gravitational torque respectively. The third term models the mechanism for escapement ($\epsilon_i$) and dampening ($D$) as a function of pendulum angle. Lastly, the fourth term accounts for the coupling of the table where $x$ is the horizontal motion of the table in the direction of the pendulums’ motion. Modifying these parameters changes the way in which the pendulums synchronize with one another or fail to do so entirely for example if the tempos of the pendulum (a determined by their length, r) are too far apart or if the mass of the table is too large. Synchronization time is proportional with natural tempo spread: metronomes take longer to phase align when their natural tempos are different. Similarly, if the dampening factor is too large, the escapement mechanism fails to induce the metronomes into periodic motion. 

## About Coupled Oscillator Models<a name="generative-models"></a>
### Kuramoto Model: Generalized Continuous Coupling 

Kuramoto oscillators are a type of limit-cycle oscillator with natural frequencies, $\omega_i$, and a coupling coefficient, $k_i$ that continually adjusts their phases according to a sinusoidal phase response curve. The natural frequencies are typically drawn from a normal distribution and since coupling is applied at all times, synchrony can result if coupling surpasses a critical coupling value. The governing equation for a group of $N$ Kuramoto oscillators is shown in the equation below.

$$\dot{\phi_i} = \omega_i + \frac{K_i}{N} \sum_{j!=i}^{N} sin(\phi_j - \phi_i)$$

### Phase Coherence, Order Parameters
What sort of metrics can indicate the level of global synchrony in the system? For any collection of instantaneous phase states $\phi_N$, we can look at a summary statistic known as the “phase coherence” that provides a useful indication of the group’s synchrony. This is shown in the equation below.

$$ Re^{j\psi} = \frac{1}{N} \sum_{i=1}^{N} e^{j\phi_i} $$

$R$ is the phase coherence magnitude and $\psi$ is what is known as the average angle. Mapping each phase state of the oscillators above onto a circle (0-2$\Pi$), we can derive an expression that relates the relative spread or dispersion of the swarm of phases of each oscillator to an R value between 0 and 1 and an average angle, $\psi$. This measure of phase coherence will become useful to describe the dynamics associated with the continuous coupling model. Moreover, this statistic can be meaningfully applied as a proxy for perceptual rhythmic entrainment which has been looked at in my other [research](https://www.academia.edu/49240274/Extracting_beat_from_a_crowd_of_coupled_metronomes_Effects_of_coupling_strength_and_timbre_on_tapping_synchronization).

We can use the mean-field of the phase coherence to rewrite the governing equation for the Kuramoto model in terms of the $|R|$ and $\psi$ as shown below. 

$$ \dot{\phi_i} = \omega_i + \Lambda_e(\phi_i) + K_i(R) sin(\psi - \phi_i) $$

### Pulse Coupling 

Kuramoto coupling is a specific instance of continuous coupling: oscillators are sharing phase information with each other continuously and making adjustments accordingly. In a pulse-coupling configuration, each oscillator triggers the other oscillators to make phase adjustments every time it completes one cycle (upon each zero crossing). Due to this fundamental difference in how coupling is carried out, pulse coupled oscillators contain different dynamics than those of Kuramoto oscillators and have more real-world validity to describe systems of fireflies [[2]](#2), animal chorusing [[3]](#3) as well as modeling the dynamics of spiking neuronal populations [[4]](#4). A mathematical description of pulse coupled oscillators is beyond the scope of this paper but has been examined in more depth at in my other [research](https://www.nolanlem.com/pdfs/smc_2022-current.pdf).



https://user-images.githubusercontent.com/1406597/217811507-f635e668-0785-4fd7-ab4e-998aae70a9d2.mp4


### Simulation of Crowd Applause Demo 

https://user-images.githubusercontent.com/1406597/217825100-1dd00080-81e4-4adc-a72d-358ceaec49ef.mov


# Basic Tutorial <a name="tutorial"></a>

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

# Keystrokes Guide <a name="keystrokes"></a>
CRT comes with built-in keystrokes so that users can interact with the parameters more quickly from their keyboards. 

'f' = toggle display mode (grid view or circle map view)
'=' = add oscillator to group
'-' = remove oscillator from group
'k' = apply Kuramoto Model Coupling 
'p' = apply Pulse Coupling 
'1' = select all active oscillators 
'0' = deselect all active oscillators 
'2' = turn on 'R Feedback' to Force System into Desired Phase Coherence 
'a' = Set in current parameter states to selected oscillators 

# UI Guide <a name="ui-guide"></a>
### Sliders
* 'KN' - adjusts the coupling for the oscillators currently selected (in green) in the selection matrix. 
* 'FREQ_I' - adjusts the natural frequency for the oscillators currently selected in the selection matrix 
* 'FREQ_E' - adjusts the frequency of the external force applied to the oscillators selected in the selection matrix 
* 'CFF' - adjusts the strength of the extenal force applied to the oscillators selected in the selection matrix
* 'F_SPREAD' - adjusts the variance of natural frequencies that are applied to all of the oscillators
* 'R TARGET' - adjusts the 'target phase coherence (|R|)' when 'R Feedback' ('2') is applied 
### Buttons
* 'RANDOM' - randomizes all the instantaneous phases of the oscillators 
* 'GLOBAL' - selects all of the active oscillators in the selection matrix 
### I/O
* 'LOADER' - loads the saved states of the system parameters onto the generative model  
* 'WRITER' - saves the current system parameters to a time-stamped text file in './saved-states'



## References
<a id="1">[1]</a> 
Pantaleone, James (Oct. 2002). 
“Synchronization of metronomes”.
American Journal of Physics 70.10, pp. 992–1000. issn: 0002-9505. doi: 10.1119/1.1501118. url: http://aapt.scitation. org/doi/10.1119/1.1501118.

<a id="2">[2]</a>
Hartbauer, Manfred and Heiner Römer (2016). 
“Rhythm generation and rhythm perception in insects: The evolution of synchronous choruses”.
Frontiers in Neuroscience 10.MAY, pp. 1–15. issn: 1662453X. doi: 10.3389/fnins.2016.00223.

<a id="3">[3]</a> 
Ravignani, Andrea, Dan Bowling, and W. Tecumseh Fitch (2014). 
“Chorusing, synchrony and the evolutionary functions of rhythm”. 
Frontiers in Psychology 5.SEP, pp. 1–15. issn: 16641078. doi: 10.3389/fpsyg.2014.01118.


<a id="4">[4]</a>
Peskin, C.S. (1975). 
Mathematical Aspects of Heart Physiology. 
New York: New York University, pp. 268–278.





