extends Resource
class_name abstract_terrain_info 
enum terrainTypes{SOLID,SAND,DIRT}


#This corresponds to solid, sand, dirt, but also increasing hardnesses in our terrains
@export var terrainIdentifier:int
@export var terrainHP:int
@export var DestroyParticleColor:Color
@export var DestroyIndvidualParticleColor:Color
