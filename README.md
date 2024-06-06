# Ocean Cleanup Vehicle Controls Application
*Team Members: Matthew Armstrong, William Fitzgerald, Jake Gustafson, and Amy Law*

Incorporates Bluetooth and location services to operate a vehicle used for ocean cleanup. See the vehicle's associated firmware and hardware components [here](https://github.com/matthewarmstr/ocean-cleanup-rov-controls.cydsn).

This project was developed as part of our UC Davis ECS 193 Senior Design Project in coordination with an EEC 136 design team. Special thanks to Professor Christopher Nitta and Teaching Assistant Ajay Suresh for their guidance and support throughout the project.

For a video demo of the vehicle's movement and app functionality in the water, click [here](https://youtu.be/D7lKjhqHaHg).

## Interface Overview
The application utilizes two views. The initial view presents a list of all available Bluetooth devices advertising a service UUID that corresponds to our associated firmware. This allows a fleet of ocean cleanup vehicles to be easily visible and controlled. On selection of a peripheral from the list, users are navigated to a controls view. The controls view presents buttons to open the trash gate, start the motor, and move the rudder so that the boat moves left or right. This view also provides the distance to the peripheral from the user (labeled 'distance from'), the distance between the boat and the nearest object ahead of it (labeled 'object ahead in'), and the direction relative to true north that the vehicle is from the user. A toggle also allows for all measurements to be displaced in either metric or imperial units.

<img src="https://github.com/matthewarmstr/ocean-cleanup-app/assets/130256280/06f33d17-29ce-47c9-a51b-16309bbd2ba3" width="200" height="433" />
<img src="https://github.com/matthewarmstr/ocean-cleanup-app/assets/130256280/fa6389bb-7134-4d46-9361-5b03d71c0293" width="541.33" height="250" />

## Application Prerequisites and Requirements
1. iOS 16 (see a list of compatible devices [here](https://support.apple.com/en-us/103267))
2. XCode *(developed using version 15.2)*
3. Swift *(developed using Swift 5)*
4. SwiftUI

## Installation and Deployment
1. Clone this repository as a new XCode project.
2. Build and follow instructions to run. Change the build identifier as necessary.
