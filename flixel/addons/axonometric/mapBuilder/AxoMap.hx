package flixel.addons.axonometric.mapBuilder ;
import flash.geom.Point;
import flixel.group.FlxGroup;
import flixel.addons.axonometric.mapBuilder.blueprint.*;
import flixel.addons.axonometric.mapBuilder.tools.*;
import flixel.addons.axonometric.spriteBuilder.*;
import flixel.FlxG;

/**
 * An instance of a map, the display object of this library
 * 
 * @author	AS3 Original: Miguel Ángel Piedras Carrillo; 
 * 			Original Haxe 2.10 Port: Masadow
 * 			Second Haxe Port: Tiago Ling Alexandre
 */
class AxoMap extends FlxGroup
{
	private var model:Model;
	private var position:AxisManager;
	private var centerPoint:Point;
	private var leftSided:Bool;
	private var geography:String;
	private var topography:String;	
	private var debug:Bool;

	/**
	 * Creates a map object
	 * 
	 * @param	x						x coodrinate of the center of the map.
	 * @param	y						y coodrinate of the center of the map.
	 * @param	theta					Angle measured in radians, it defines the shape of the plane yx(for correct functionality , theta+phi must form an angle bigger thanPI).
	 * @param	phi						Angle measured in radians, it defines the shape of the plane xz(for correct functionality , theta+phi must form an angle bigger than PI).
	 * @param	descriptor				BlockDescriptor object.
	 * @param	debug					Sets the debugging mode.
	 */		
	public function new(x:Float, y:Float, theta:Float, phi:Float, descriptor:BlockDescriptor, debug:Bool = false)
	{			
		super();
		centerPoint = new Point(x,y);
		position = new AxisManager(descriptor, centerPoint);
		position.setAxis(theta, phi, debug);
		this.debug = debug;
		leftSided = (theta > 0);			
	}
	
	
	 /** 
	 * Renders the map images . Returns true on succesful rederization.
	 * 
	 * @param	topography				String with columns that are made of numbers separated by comas, and rows separated by line breaks, it defines the shape of the map
	 * @param	geography				(OPTIONAL)String with columns that are made of numbers separated by comas, and rows separated by line breaks, it defines the texture of the map,
	 * 									it must be of the same dimentions of topography.
	 */		
	public function RenderMap(topography:String, geography:String = ""):Bool 
	{
		this.topography=topography;
		this.geography=geography;
		model = new Model(geography, topography, leftSided);
		add(new Layer(model.root, position, debug));

		return true;
	}
	
	 /**
	 * Adds an element to the world, if the position is invalid, it will be set on 0,0
	 * 
	 * @param	i						Position of the row to put the sprite, given the topography as reference
	 * @param	j						Position of the column to put the sprite, given the topography as reference
	 * @param	sprite					sprite of the AxonometricSprite class to be added to stage 
	 */
	public function AddElement(i:Int, j:Int, sprite:AxonometricSprite):Void 
	{
		if (leftSided)
		{
			j = (model.maxCols - 1) - j;
		}
		var node:Node = model.getNodeInPos(i, j);
		if (node == null) 
		{
			node = model.getNodeInPos(0, 0);
			i = 0;
			j = 0;
		}
		sprite.currentNode = node;
		sprite.map = this;
		SetSpriteBelongingLayer(sprite, i, j);
		var point:Point = position.Get2DLocationFromTopography(i, j, node.heightfromground);
		sprite.setLocation(point.x, point.y);
	}
	
	private function SetSpriteBelongingLayer(sprite:AxonometricSprite, i:Int, j:Int):Void 
	{	
		if ((sprite.checkedi != i) || (sprite.checkedj != j)) 
		{
			sprite.checkedi = i;
			sprite.checkedj = j;
			var centerNode:Node = model.getNodeInPos(i, j);
			var ND:Array<Node> = new Array<Node>();
			var south:Node = model.getNodeInPos(i+1, j);
			var node:Node;
			var select:Node = centerNode;
			var biggerLayer:Float = centerNode.platformRender.mylayer;
			
			ND.push(model.getNodeInPos(i - 1, j - 1));
			ND.push(model.getNodeInPos(i - 1, j));
			ND.push(model.getNodeInPos(i - 1, j + 1));
			ND.push(model.getNodeInPos(i, j - 1));
			ND.push(model.getNodeInPos(i, j + 1));
			ND.push(model.getNodeInPos(i + 1, j - 1));
			ND.push(model.getNodeInPos(i + 1, j));
			ND.push(model.getNodeInPos(i + 1, j + 1));
 			
 			var numNodes:Int = ND.length;
			for (i in 0...numNodes) 
			{
				node = ND[i];
				if (node != null) 
				{
					if (node.heightfromground == centerNode.heightfromground) 
					{
						if (node.platformRender.mylayer > biggerLayer) 
						{						
							biggerLayer = node.platformRender.mylayer;
							select = node;
						}
					} 
					else if (node.heightfromground > centerNode.heightfromground && centerNode.northenNeighbors.get(node.tag) == null) 
					{
						select = centerNode;
						break;
					}
				}
			}							
			RemoveElement(sprite);
			sprite.currgroup = select.platformRender;
			sprite.currgroup.add(sprite.shadow);
			sprite.currgroup.add(sprite);
		}
	}				
	
	/**
	 * Removes a sprite from the world
	 * 
	 * @param	sprite					sprite of the AxonometricSprite class to be added to stage 
	 */		
	public function RemoveElement(sprite:AxonometricSprite):Void 
	{
		if (sprite.currgroup != null) 
		{
			sprite.currgroup.remove(sprite);
			sprite.currgroup.remove(sprite.shadow);
			sprite.currgroup = null;
		}
	}

	 /**
	 * cheks and changes the current bounds and location of the sprite.
	 * 
	 * @param	sprite						the sprite to be checked
	 */
	public function CheckBounds(sprite:AxonometricSprite):Void 
	{
		// ->->	 ->
		// P=αa  +  βb 	
		var P:Point = new Point(sprite.shadow.x - sprite.currentNode.platformRender.floor.X, sprite.shadow.y - sprite.currentNode.platformRender.floor.Y);

		var alpha:Float = GetAlpha(P, position.axisX, position.axisZ);
		var beta:Float = GetBeta(P, position.axisX, position.axisZ);
		var correctionalpha:Float = alpha;
		var correctionbeta:Float = beta;			
		var currcol:Int = Math.floor(alpha / position.descriptor.BlockWidth);
		var currrow:Int = Math.floor(beta  / position.descriptor.BlockDepth);
		var touchingNeighboor:Bool = false;

		if (currcol > sprite.currentNode.cols - 1) 
		{
			touchingNeighboor = true;
			correctionalpha = sprite.currentNode.cols * position.descriptor.BlockWidth;
		}
		if (currcol < 0) 
		{
			touchingNeighboor = true;
			//TODO: Find the correct constant to substitute this
			// correctionalpha=Number.MIN_VALUE;
			correctionalpha = 4.9406564584124654e-324;
		}
		if (currrow > sprite.currentNode.rows - 1) 
		{
			touchingNeighboor = true;
			correctionbeta = sprite.currentNode.rows * position.descriptor.BlockDepth;
		}			
		if (currrow < 0) 
		{
			touchingNeighboor = true;
			//TODO: Find the correct constant to substitute this
			// correctionbeta=Number.MIN_VALUE;
			correctionbeta = 4.9406564584124654e-324;
		}						
		if (touchingNeighboor) 
		{
			var neighbor:Node = model.getNodeInPos(sprite.currentNode.Ti + currrow, sprite.currentNode.Tj + currcol);
			if (neighbor == null) 
			{
				SpriteTouchesLimits(sprite, correctionalpha, correctionbeta);
			}
			else 
			{
				var dropheight:Float = sprite.currentNode.heightfromground - neighbor.heightfromground;
				if (dropheight == 0) 
				{
					ChangeNode(sprite, neighbor, (sprite.currentNode.Ti +  currrow), (sprite.currentNode.Tj + currcol));
				}
				else 
				{
					if (sprite.shadow.walldrop(dropheight * position.descriptor.BlockHeight)) 
					{
						ChangeNode(sprite, neighbor, (sprite.currentNode.Ti +  currrow), (sprite.currentNode.Tj + currcol));
					}
					else 
					{
						SpriteTouchesLimits(sprite, correctionalpha, correctionbeta);
					}
				}
			}
		}
		else 
		{
			SetSpriteBelongingLayer(sprite, (sprite.currentNode.Ti + currrow), (sprite.currentNode.Tj + currcol));
		}
	}
	
	private function ChangeNode(sprite:AxonometricSprite, newnode:Node, i:Float, j:Float):Void 
	{
		sprite.currentNode=newnode;
	}
			
	private function SpriteTouchesLimits(sprite:AxonometricSprite, correctionalpha:Float, correctionbeta:Float):Void 
	{
		var correction:Point = new Point(position.axisX.x * correctionalpha + position.axisZ.x * correctionbeta,
			position.axisX.y * correctionalpha + position.axisZ.y * correctionbeta);
		correction.x += sprite.currentNode.platformRender.floor.X;
		correction.y += sprite.currentNode.platformRender.floor.Y;
		sprite.shadow.x = correction.x;
		sprite.shadow.y = correction.y;
	}

	private function GetAlpha(P:Point, a:Point, b:Point):Float 
	{
		return((P.x / a.x) - (b.x / a.x) * GetBeta(P, a, b));
	}

	private function GetBeta(P:Point, a:Point, b:Point):Float 
	{
		return((P.y - (a.y / a.x) * P.x) / (b.y - (a.y / a.x) * b.x));
	}

	/**
	 * Destroys this element, freeing memeory.
	 * 
	 */		
	override public function destroy():Void 
	{			
		this.kill();
		model.destroy();
		position.destroy();
	}	
	
}