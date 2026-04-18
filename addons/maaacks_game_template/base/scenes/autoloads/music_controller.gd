class_name MusicController
extends Node
## Controller for music playback across scenes.
##
## This node persistently checks for stream players added to the scene tree.
## It detects stream players that match the audio bus and have autoplay on.
## It then reparents the stream players to itself, and handles blending.
## The expected use-case is to attach this script to an autoloaded scene.

## ... But it was redundant and broke some code, so I removed it entirely.
