package flixel.addons.axonometric.mapBuilder.tools.parallelogramRendering;

import flixel.FlxObject;

/**
 * a helper object to render paralelograms, modified from the original.
 * 
 * @author	Adam Atomic(original)Miguel Ángel Piedras Carrillo(Modificado)
 */
class ParallelTile extends FlxObject
{
	/**
	 * This function is called whenever an object hits a tile of this type.
	 * This function should take the form<code>myFunction(Tile:ParallelTile,Object:FlxObject):Void</code>.
	 * Defaults to null, set through<code>ParallelTilemap.setTileProperties()</code>.
	 */
	public var callback:ParallelTile->FlxObject->Void;
	
	/**
	 * Each tile can store its own filter class for their callback functions.
	 * That is, the callback will only be triggered if an object with a class
	 * type matching the filter touched it.
	 * Defaults to null, set through<code>ParallelTilemap.setTileProperties()</code>.
	 */
	public var filter:Class<Dynamic>;
	
	/**
	 * A reference to the tilemap this tile object belongs to.
	 */
	public var tilemap:ParallelTilemap;
	
	/**
	 * The index of this tile type in the core map data.
	 * For example, if your map only has 16 kinds of tiles in it,
	 * this number is usually between 0 and 15.
	 */
	public var index:Int;
	
	/**
	 * The current map index of this tile object at this moment.
	 * You can think of tile objects as moving around the tilemap helping with collisions.
	 * This value is only reliable and useful if used from the callback function.
	 */
	public var mapIndex:Int;
	
	
	/**
	 * Instantiate this new tile object.  This is usually called from<code>ParallelTilemap.loadMap()</code>.
	 * 
	 * @param Tilemap			A reference to the tilemap object creating the tile.
	 * @param Index				The actual core map data index for this tile type.
	 * @param Width				The width of the tile.
	 * @param Height			The height of the tile.
	 * @param Visible			Whether the tile is visible or not.
	 * @param AllowCollisions	The collision flags for the object.  By default this value is ANY or NONE depending on the parameters sent to loadMap().
	 */
	public function new (Tilemap:ParallelTilemap, Index:Int, Width:Float, Height:Float, Visible:Bool, AllowCollisions:Int)
	{
		super(0, 0, Width, Height);
		immovable = true;
		moves = false;
		callback = null;
		filter = null;
		
		tilemap = Tilemap;
		index = Index;
		visible = Visible;
		allowCollisions = AllowCollisions;
		
		mapIndex = 0;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		callback = null;
		tilemap = null;

		super.destroy();
	}
}