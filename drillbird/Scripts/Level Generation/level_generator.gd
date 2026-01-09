extends Node2D

@export var allTheChunks:PackedScene
@export var caveWidthInchunks:int=4
@export var caveDepthInChunks:int=4

#hmm.. need to generate some chunkers and have them increase in difficulty over time 
#Ideally the cave should have slightly different layouts per run as well, but can handle that later 

#The level generator spawns in all of the chunks that are wanted live, save them down into an array,
#and then recreates those tiles in the level..although maybe it cannot check those without spawning them?
#ideally it should have access to all of the chunk scripts from the get-go 
#Maybe the chunk scripts could save themselves down as resources, which are then accessed? So one chunk=one resource 
