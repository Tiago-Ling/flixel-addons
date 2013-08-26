package flixel.addons.axonometric.mapBuilder.blueprint ;
import flixel.addons.axonometric.mapBuilder.Platform;
import flixel.addons.axonometric.mapBuilder.tools.parallelogramRendering.*;

/**
 * A node represents a square section of the topography of the map, it also has information that it is used in the creation of the layers of the map and information to 
 * the limits of each platform
 * 
 * @author	Miguel Ángel Piedras Carrillo
 */
class Node 
{		
	/**
	 * section of the topography that corresponds with this node
	 */
	public var geography:String;	
	
	/**
	 * northen neighbors of the node
	 */
	public var northenNeighbors:Map<String, NodeLink>;
	
	/**
	 * sourthern neighbors of the node
	 */
	public var southernNeighbors:Map<String, NodeLink>;
	
	/**
	 * eastern neighbors of the node
	 */
	public var easternNeighbors:Map<String, NodeLink>;
	
	/**
	 * western neighbors of the node
	 */
	public var westernNeighbors:Map<String, NodeLink>;
	
	/**
	 * column of the leftmost, uppermost tile of the node
	 */		
	public var Ti:Int;
	
	/**
	 * row of the leftmost, uppermost tile of the node
	 */		
	public var Tj:Int;	
	
	/*
	 * height of the platform from the ground
	 */		
	public var heightfromground:Int;
	
	/**
	 * x position of the world
	 */
	public var x:Float;
	
	/**
	 * y position fo the world
	 */
	public var y:Float;
	
	/**
	 * z position of the world
	 */
	public var z:Float;	
	
	/**
	 * amount of colums of this node
	 */
	public var cols:Int;
	
	/**
	 * amount of rows of this node
	 */
	public var rows:Int;
	
	/**
	 * tagname assigned to this node
	 */		
	public var tag:String;	
	
	/*
	 *  graphical object that is the representation of this node
	 */ 		
	public var platformRender:Platform;
	
	/*
	 * parent of this node(part of a tree structure used for the layer creation)
	 */ 		
	public var parent:Node;		
	
	/*
	 * children of this node(part of a tree structure used for the layer creation)
	 */ 		
	public var children:Map<String, Node>;
	
	/**
	 * Constructor
	 * 
	 * @param	tag		tagname assigned to this node.
	 * @param	cols	amount of colums of this node.
	 * @param	rows	amount of rows of this node.
	 * @param	Ti		row regarding the original topography.
	 * @param	Tj		column regarding the original topography.
	 * @param   height  heigh of the platform
	 * 
	 */		
	public function new(tag:String, cols:Int, rows:Int, Ti:Int, Tj:Int, height:Int)
	{
		this.tag = tag;
		this.cols = cols;
		this.rows = rows;
		this.Ti = Ti;
		this.Tj = Tj;		
		this.heightfromground = height;
		geography = "";
		this.x	= Tj;
		this.y	= 0;//-height;
		this.z	= Ti;
		
		northenNeighbors = new Map<String, NodeLink>();
		southernNeighbors = new Map<String, NodeLink>();
		easternNeighbors = new Map<String, NodeLink>();
		westernNeighbors = new Map<String, NodeLink>();
		children = new Map<String, Node>();
		parent = null;
	}
	
	/**
	 * adds a western neighbor
	 * 
	 * @param node neigbor to add
	 *
	 */		
	public function AddWesternNeighborsLink(node:Node):Void 
	{
		SetLink(westernNeighbors, node.easternNeighbors, node);
	}
	
	/**
	 * adds a western neighbor
	 * 
	 * @param node neigbor to add
	 *
	 */		
	public function AddEasternNeighborsLink(node:Node):Void 
	{
		SetLink(easternNeighbors, node.westernNeighbors, node);
	}
	
	/**
	 * adds a northern neighbor
	 * 
	 * @param node neigbor to add
	 *
	 */		
	public function AddNorthenNeighbors(node:Node):Void 
	{
		SetLink(northenNeighbors, node.southernNeighbors, node);
	}
	
	/**
	 * adds a southern neighbor
	 * 
	 * @param node neigbor to add
	 *
	 */		
	public function AddSouthernNeighbors(node:Node):Void 
	{
		SetLink(southernNeighbors, node.northenNeighbors, node);
	}
	
	private function SetLink(MyNeighbors:Map<String, NodeLink>, HisNeighbors:Map<String, NodeLink>, node:Node):Void 
	{
		var link:NodeLink;
		link = HisNeighbors.get(tag);
		if (link != null)
		{
			MyNeighbors.set(node.tag, link);
		}
		else 
		{
			link = MyNeighbors.get(node.tag);
			if (link != null)
			{
				link.Linkspan++;
			}
			else 
			{
				if (node.heightfromground > heightfromground) 
				{
					link = new NodeLink(node, this);
				}
				else if (node.heightfromground < heightfromground)
				{
					link = new NodeLink(this, node);
				}
				else 
				{
					link = new NodeLink(node, this, true);
				}
				MyNeighbors.set(node.tag, link);
			}
		}
	}

	
	/** 
	 * sets the string that defines the shape of the lateral sides of the node
	 * 
	 * @param Neighboors	 wich neighbors are used to create this string
	 * @param horizontal	 if the neighbors are horizontal to the node
	 * 
	 */
	public function getLateralMapString(Neighboors:Map<String, NodeLink>,horizontal:Bool=true):String 
	{
		//retrieve all the neighbors
		var ordered:Array<Node> = new Array();
		var link:NodeLink;
		var map:String = "";
		for (link in Neighboors)
		{
			ordered.push(link.getNeighbor(this));
		}
		if (ordered.length == 0)
		{
			//return a default string in case of an empty size
			if (horizontal)
			{
				return GenerateLateralGeography(cols, heightfromground);
			}
			else 
			{
				return GenerateLateralGeography(rows, heightfromground);
			}
		}
		else 
		{
			ordered = Model.QuickSortNodes(ordered, horizontal);
			var rowpart:String = "";
			var row:String = "";
			var lastaxis:Int;
			var allzeros:Bool = false;
			var gap:Int = 0;
			var lenght:Int = 0;
			var i:Int = 0;
			var j:Int = 0;
			while (!allzeros)
			{
				allzeros = true;
				lenght = 0;
				if (horizontal) 
				{
					lastaxis = this.Tj;
				}
				else 
				{
					lastaxis = this.Ti;
				}
				//iterate through the neighboors
				var numOrdered:Int = ordered.length;
				for (i in 0...numOrdered) 
				{
					//check if there is a gap between the last node and this
					if (horizontal) 
					{
						gap = Std.int(ordered[i].Tj - lastaxis);
					}
					else
					{
						gap = Std.int(ordered[i].Ti - lastaxis);
					}
					if (gap > 0)
					{
						rowpart = getrowpart(gap, 0);
						lenght += gap;
						row += buildnextrowpart(row, rowpart);
					}
					//add the next node part of the row
					if (Neighboors.get(ordered[i].tag).isUpperNode(this)) 
					{
						if (j >= Neighboors.get(ordered[i].tag).Height) 
						{
							rowpart = getrowpart(Neighboors.get(ordered[i].tag).Linkspan, 0);
						}
						else 
						{
							rowpart = getrowpart(Neighboors.get(ordered[i].tag).Linkspan, 1);
							allzeros = false;
						}
					}
					else 
					{
						rowpart=getrowpart(Neighboors.get(ordered[i].tag).Linkspan, 0);
					}
					lenght += Neighboors.get(ordered[i].tag).Linkspan;
					row += buildnextrowpart(row,rowpart);								
					//get the value to check gaps
					if (horizontal)
					{
						lastaxis = Std.int(ordered[i].Tj + ordered[i].cols);
					}
					else
					{
						lastaxis = Std.int(ordered[i].Ti + ordered[i].rows);
					}
				}					
				//check if there is a gap in the end
				if (horizontal) 
				{
					gap = lenght - this.cols;
				}
				else 
				{
					gap = lenght - this.rows;
				}
				if (gap != 0)
				{
					rowpart = getrowpart(gap, 0);
					row += buildnextrowpart(row, rowpart);
				}										
				if (!allzeros)
				{
					if (j == 0)
					{
						map += row;
					}
					else 
					{
						map += "\n" + row;
					}
				}
				row = "";
				j++;
			}
		}
		return map;
	}
	
	private function buildnextrowpart(row:String, rowpart:String):String 
	{
		if (row == "") 
		{
			return "" + rowpart;
		}
		else 
		{
			return "," + rowpart;
		}
		return "";
	}
	
	private function getrowpart(lenght:Int, value:Float):String 
	{
		var i:Int = 0;
		var result:String = "";
		for (i in 0...lenght) 
		{
			result += "" + value;
			if ((i + 1) < lenght)
			{
				result += ",";
			}
		}
		return result;
	}		
	
	private function GenerateLateralGeography(Width:Int, Height:Int):String 
	{
		var i:Int;
		var j:Int;
		var lateralgeography:String = "";
		for (i in 0...Height) 
		{
			for (j in 0...Width) 
			{
				lateralgeography += "1";
				if ((j + 1) != Width) 
				{
					lateralgeography += ",";
				}
				else if ((i + 1) != Height) 
				{
					lateralgeography += "\n";
				}
			}
		}
		return lateralgeography;
	}
	
	/*
	 * sets a node as a child of this parent
	 */ 		
	public function addChild(node:Node):Void 
	{
		var name:String = getBoatName(node);
		children.set(name, node);
	}
	
	/*
	 * removes a node as a child of this parent
	 */ 		
	public function removeChild(node:Node):Void 
	{
		var name:String = getBoatName(node);
		children.set(name, null);		
	}
	
	private function getBoatName(node:Node):String 
	{
		return node.tag;
	}
	
	/**
	 * Destroys this element, freeing memeory.
	 * 
	 */
	public function destroy():Void 
	{
		destroyneighborobjec(northenNeighbors);
		destroyneighborobjec(southernNeighbors);
		destroyneighborobjec(westernNeighbors);
		destroyneighborobjec(easternNeighbors);
		
	}
	
	private function destroyneighborobjec(neighboors:Map<String, NodeLink>):Void 
	{
		for (key in neighboors)
		{
			key = null;
		}
		neighboors = null;
	}
	
}