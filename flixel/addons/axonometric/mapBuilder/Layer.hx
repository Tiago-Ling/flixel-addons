package flixel.addons.axonometric.mapBuilder ;

import flixel.addons.axonometric.mapBuilder.blueprint.Model;
import flixel.addons.axonometric.mapBuilder.blueprint.Node;
import flixel.addons.axonometric.mapBuilder.tools.AxisManager;
import flixel.group.FlxGroup;

/**
 *   A layer has a collection of the objects shown in screen
 * @author Miguel Ángel Piedras Carrillo
 */
class Layer extends FlxGroup
{		

	private var layerNodes:Array<Node>;
	
	/**
	 * contructor of the layer
	 * 
	 * @param level  Sets the level of the layer
	 * 
	 */ 		
	public function new(node:Node,position:AxisManager,debug:Bool)
	{
		super();
		layerNodes = new Array();
		RenderBoats(node, position, debug);
	}
	
	private function RenderBoats(current:Node, position:AxisManager, debug:Bool):Void 
	{
		var i:Float;
		var layer:Layer;
		for (key in current.children)
		{
			layerNodes.push(key);
		}			
		layerNodes = Model.QuickSortNodes(layerNodes, true);
		var numNodes:Int = layerNodes.length;
		for (i in 0...numNodes) 
		{
			add(new Layer(layerNodes[i],position,debug));
		}
		if (current.parent != null)
		{
			current.platformRender = new Platform(current, position, debug);
			add(current.platformRender);				
		}
		
	}		
	
	/**
	 * Destroys this element, freeing memeory.
	 * 
	 */
	override public function destroy():Void 
	{
		super.kill();		
	}
}