package flixel.addons.axonometric.mapBuilder;

import flixel.addons.axonometric.mapBuilder.tools.AxisManager;
import flixel.addons.axonometric.mapBuilder.tools.ParallelogramReference;
import flixel.addons.axonometric.mapBuilder.tools.parallelogramRendering.*;
import flixel.addons.axonometric.mapBuilder.blueprint.*;
import flash.geom.Point;
import flixel.group.FlxGroup;

/**
 * A platform is the rendering of a node, the graphical part of the floor
 * 
 * @author	AS3 Original: Miguel Ángel Piedras Carrillo; 
 * 			Original Haxe 2.10 Port: Masadow
 * 			Second Haxe Port: Tiago Ling Alexandre
 */
class Platform extends FlxGroup
{
	/*
	 *  the floor of the platform
	 */ 
	public var floor:ParallelTilemap;
	/*
	 *  the right side of the platform
	 */ 
	public var sideB:ParallelTilemap;
	/*
	 *  the left side of the platform
	 */ 
	public var sideA:ParallelTilemap;
	
	public static var layernum:Float = 0;
	/*
	 *  the number of the current layer
	 */ 
	public var mylayer:Float;

	/**
	 * Constructor
	 * 
	 * @param	node			node to be rendered Into a platfom
	 * @param	position		instance of axismanager to guide the rendering
	 * @param	debug			sets the debugging mode
	 * 
	 */
	public function new(node:Node, position:AxisManager, debug:Bool = false)
	{
		super();
		MakeParallelepiped(node, position, debug);
		mylayer = layernum;
		layernum++;
	}

	private function MakeParallelepiped(node:Node, Pos:AxisManager, debug:Bool, cannonical:Bool = false):Void 
	{
		var geography:String = node.geography;
		var geographyB:String;
		var geographyA:String;
		
		geographyB = node.getLateralMapString(node.southernNeighbors, true);
		geographyA = node.getLateralMapString(node.easternNeighbors, false);
		sideB = MakeParallelepipedSide(geographyB, Pos.sideBReference);
		sideA = MakeParallelepipedSide(geographyA, Pos.sideAReference);
		floor = MakeParallelepipedSide(geography, Pos.floorReference);
		this.add(sideB);//xy
		this.add(sideA);//yz
		this.add(floor);//xz

		//we are using the width, because both of the tilemaps are rotated
		var Parallelepipedheight:Float = (sideB.widthInTiles > sideA.widthInTiles) ? sideB.widthInTiles : sideA.widthInTiles;
		var x:Float = node.x * Pos.descriptor.BlockWidth;
		var y:Float = (node.heightfromground - Parallelepipedheight) * (-Pos.descriptor.BlockHeight);
		var z:Float = node.z * Pos.descriptor.BlockDepth;
		 
		var Location:Point = Pos.Get2dCord(x, y, z);
		Location.x += Pos.center.x;
		Location.y += Pos.center.y;

		//transformed/working state
		if (!cannonical)
		{
			
			floor.setLocation(Location.x - Pos.axisY.x *Pos.descriptor.BlockHeight* Parallelepipedheight,
							Location.y - Pos.axisY.y *Pos.descriptor.BlockHeight* Parallelepipedheight);
			sideB.setLocation(Location.x + floor.BigAxisB.x, Location.y + floor.BigAxisB.y);
			sideA.setLocation(Location.x + floor.BigAxisA.x, Location.y + floor.BigAxisA.y);
			
			//putting the thing together if there is a difference in the sides height
			sideB.setLocation(sideB.X -  Pos.axisY.x*Pos.descriptor.BlockHeight*(Parallelepipedheight-sideB.widthInTiles),
							  sideB.Y -  Pos.axisY.y*Pos.descriptor.BlockHeight*(Parallelepipedheight-sideB.widthInTiles));	
			sideA.setLocation(sideA.X -  Pos.axisY.x*Pos.descriptor.BlockHeight*(Parallelepipedheight-sideA.widthInTiles),
							  sideA.Y -  Pos.axisY.y * Pos.descriptor.BlockHeight * (Parallelepipedheight - sideA.widthInTiles));
							  
		}
		else 
		{ 
			//cannonical form, it shows the "center" of the block
			floor.setLocation(Location.x, Location.y);
			sideB.setLocation(Location.x, Location.y);
			sideA.setLocation(Location.x, Location.y);
		}
	}
	
	private function MakeParallelepipedSide(geography:String, reference:ParallelogramReference):ParallelTilemap
	{			
		var map:ParallelTilemap = new ParallelTilemap();
		map.loadMap(geography, reference);
		map.scrollFactor.x = 1;
		map.scrollFactor.y = 1;
		return map;
	}
		
	/**
	* Destruye el objeto y sus elementos, liberando memoria
	* 
	*/		
	override public function destroy():Void 
	{
		floor.destroy();
		sideB.destroy();
		sideA.destroy();
	}
}