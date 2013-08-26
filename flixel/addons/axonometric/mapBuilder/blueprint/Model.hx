package flixel.addons.axonometric.mapBuilder.blueprint ;

/**
 * Sets the model wich serves as a blueprint to create the stage
 * 
 * @author Miguel Ángel Piedras Carrillo
 */
class Model 
{		
	/**
	 *  The amount of rows of the map
	 */
	public var maxRows:Int = 0;
	
	/**
	 *  The amount of cols of the map
	 */
	public var maxCols:Int = 0;
	
	/**
	 * The array of nodes genereted at creating the model
	 */
	public var nodes:Array<Node>;
	
	/**
	 * An array of the nodes created for easy access
	 */
	public var nodesObject:Map<String, Node>;
	
	/**
	 * the roots of the tree structure created for the layer creation;
	 */
	public var root:Node;
	
	private var geography:Array<String>;
	private var topography:Array<String>;
	private var nodeCount:Int;		
	
	/**
	 * The contructor of the class
	 * 
	 * @param	geographyMap	string that represents by numbers separated by commas and line breaks the tile of the floor in each given position.
	 * @param	topographyMap	string that represents by numbers separated by commas and line breaks the height of the floor in each given position.
	 * @param	invertNodes		inverts the order of the nodes, for when the orientation of the map is "leftsided"
	 */		
	public function new(geographyMap:String, topographyMap:String, invertNodes:Bool)
	{		
		nodeCount = 0;			
		geography = new Array<String>();
		topography = new Array<String>();
		nodes = new Array<Node>();
		nodesObject = new Map<String, Node>();
		GenerateMap(topographyMap, topography, invertNodes);
		GenerateMap(geographyMap,  geography, invertNodes);
		GenerateNodes();
		GenerateNodeLinks();
	}
	
	private function GenerateMap(pMap:String, Arr:Array<String>, invertNodes:Bool):Void 
	{			
		var i:Int = 0;
		var j:Int = 0;
		if (pMap == "") 
		{
			for (i in 0...maxRows) 
			{
				for (j in 0...maxCols) 
				{
					Arr.push("1");
				}
			}
		}
		else
		{
			var columns:Array<Dynamic>;
			var rows:Array<Dynamic> = pMap.split("\n");
			maxRows = rows.length;
			maxCols = 0;
			while (i < maxRows)
			{
				columns = rows[i++].split(",");
				if (maxCols == 0)
					maxCols = columns.length;
				j = 0;
				while (j < maxCols) 
				{										
					if (!invertNodes) 
					{
						Arr.push(columns[j]);
					}
					else 
					{
						Arr.push(columns[maxCols - 1 - j]);
					}
					j++;
				}
			}
		}
	}
	
	private function GenerateNodes(debug:Bool = false):Void 
	{
		var i:Int = 0;
		var j:Int = 0;
		for (i in 0...maxRows) 
		{
			for (j in 0...maxCols) 
			{
				var top:String = GetTopography(i, j);
				if (top.indexOf("N") == -1)
				{
					checkNextNode(i, j, top);
				}
			}
		}			
		if (debug)
		{
			tracecurrentTopography();
		}				
	}
	
	private function tracecurrentTopography():Void
	{
		var i:Float = 0;
		var j:Float;
		var row:String = "";			
		for (i in 0...maxRows) 
		{
			for (j in 0...maxCols) 
			{
				row += GetTopography(i, j);					
				if ((j + 1) != maxCols)
				{
					row += ",";
				}
			}
			row = "";
		}
	}
	
	private function checkNextNode(Ti:Int, Tj:Int, value:String):Void 
	{
		var rows:Int = 1;
		var cols:Int = 1;	
		var stopcol:Bool = false;
		var stoprow:Bool = false;	
		while (!stopcol || !stoprow)
		{			
			if (!stopcol)
			{
				if (tryRectangle(Ti, Tj, rows  , cols + 1, value))
				{
					cols++;
				}
				else
				{
					stopcol = true;
				}					
			}				
			if (!stoprow)
			{
				if (tryRectangle(Ti, Tj, rows + 1, cols	, value))
				{
					rows++;
				}
				else
				{
					stoprow = true;
				}								
			}
		}						
		var i:Float;
		var j:Float;
		var extra:String;
		if (nodeCount < 10)
		{
			extra = "0";
		}
		else 
		{
			extra = "";
		}
		var intValue:Int = Std.parseInt(value);
		var node:Node = new Node("N" + extra + nodeCount, cols, rows, Ti, Tj, intValue);
		for (i in 0...rows) 
		{
			for (j in 0...cols) 
			{
				SetTopography(Ti + i, Tj + j, "N" + extra + nodeCount);
				node.geography += GetGeography(Ti + i, Tj + j);
				if ((j + 1) != cols)
				{
					node.geography += ",";
				}
				else if ((i + 1) != rows)
				{
					node.geography += "\n";
				}					
			}
		}			
		nodes.push(node);
		nodeCount++;
		nodesObject.set(node.tag, node);
	}
	
	private function tryRectangle(Ti:Int, Tj:Int, rows:Int, cols:Int, value:String):Bool
	{
		var t:Float;
		if ((Ti + rows - 1) >= maxRows)
		{
			return false;
		}
		if ((Tj + cols - 1) >= maxCols)
		{
			return false;
		}
		var i:Int = 0;
		var j:Int = 0;
		for (i in 0...rows) 
		{
			for (j in 0...cols) 
			{
				if (GetTopography(Ti + i, Tj + j) != value)
				{
					return false;
				}
			}
		}
		return true;			
	}				
			
	private function GenerateNodeLinks():Void 
	{
		var i:Float = 0;
		//creates the node neighboors and parets, for the tree structure
		var numNodes:Int = nodes.length;
		for (i in 0...numNodes) 
		{
			SetNodeSides(nodes[i]);
		}
		//finds the roots of the model, and then sets them as the childs of a unique node called ROOT
		root = new Node("ROOT", 0, 0, 0, 0, 0);
		var node:Node;
		for (i in 0...numNodes) 
		{
			node = nodes[i];
			if (node.parent == null)
			{
				node.parent = root;
				root.children.set(node.tag, node);				
			}
		}				
	}
	
	private function SetNodeSides(node:Node):Void 
	{
		SetWesternSide(node);
		SetEasternSide(node);
		SetNorthernSide(node);
		SetSouthernSide(node);
		SearchNodesToAnchor(node);
	}
	
	private function SetWesternSide(node:Node):Void 
	{
		var i:Int = 0;
		for (i in 0...node.rows) 
		{
			if (SideExist(node.Ti + i, node.Tj - 1))
			{
				node.AddWesternNeighborsLink(nodesObject[GetTopography(node.Ti + i, node.Tj - 1)]);
			}
		}
	}
	
	private function SetEasternSide(node:Node):Void 
	{
		var i:Float = 0;
		var firstval:Bool = true;
		for (i in 0...node.rows) 
		{
			if (SideExist(node.Ti +(node.rows - 1 - i), node.Tj + (node.cols - 1) + 1)) 
			{
				node.AddEasternNeighborsLink(nodesObject[GetTopography(node.Ti +(node.rows - 1 - i), node.Tj + (node.cols - 1) + 1)]);
			}
		}
	}
	
	private function SetNorthernSide(node:Node):Void 
	{
		var j:Float = 0;
		var firstval:Bool = true;
		
		for (j in 0...node.cols) 
		{
			if (SideExist(node.Ti - 1, node.Tj + j)) {
				node.AddNorthenNeighbors(nodesObject[GetTopography(node.Ti - 1, node.Tj + j)]);
			}
		}
	}
	
	private function SetSouthernSide(node:Node):Void 
	{
		var j:Float=0;
		for (j in 0...node.cols) 
		{
			if (SideExist(node.Ti + (node.rows - 1) + 1, node.Tj + j)) 
			{
				node.AddSouthernNeighbors(nodesObject[GetTopography(node.Ti + (node.rows - 1) + 1, node.Tj + j)]);
			}
		}
	}		
	
	private function SearchNodesToAnchor(node:Node):Void 
	{
		var neighborlink:NodeLink;
		var neighbor:Node;
		for (key in node.northenNeighbors)
		{
			neighborlink = key;
			if (neighborlink.getNeighbor(node).parent == null)
			{
				neighborlink.getNeighbor(node).parent = node;
				node.addChild(neighborlink.getNeighbor(node));
			}
			else if (node.Tj < neighborlink.getNeighbor(node).parent.Tj)
			{
				neighborlink.getNeighbor(node).parent.removeChild(neighborlink.getNeighbor(node));
				neighborlink.getNeighbor(node).parent = node;
				node.addChild(neighborlink.getNeighbor(node));
			}
		}			
	}
	
	private function SideExist(i:Float, j:Float):Bool 
	{
		if (i<0 || i>=maxRows)
		{
			return false;
		}
		if (j<0 || j>=maxCols)
		{
			return false;
		}
		return true;
	}
	
	/**
	 * Gets the node in the corresponding i(row), j(column)coordinate, it returns null if given an invalid location
	 * 
	 * @param	i	row of the node.
	 * @param	j	columnd of the node.
	 * 
	 */		
	public function getNodeInPos(i:Int, j:Int):Node 
	{
		if (!SideExist(i, j))
		{
			return null;
		}			
		var tag:String = GetTopography(i, j);
		return nodesObject[tag];
	}		
	
	private function GetTopography(i:Int, j:Int):String 
	{
		var currentTopographyNode:String = topography[i * maxCols + j];
		return currentTopographyNode;
	}
	
	private function SetTopography(i:Int, j:Int, val:String):Void
	{
		topography[i * maxCols + j] = val;
	}
	
	private function GetGeography(i:Int, j:Int):String 
	{
		return geography[i * maxCols + j];
	}
	
	/*
	 *  static function to sort an array of nodes using quicksort
	 */ 		
	public static function QuickSortNodes(arrToSort:Array<Node>, horizontal:Bool):Array<Node> 
	{
		if (arrToSort.length <= 1)
		{
			return arrToSort;
		}			
		var pivot:Int = Math.round(Math.random() * (arrToSort.length - 1));
		var pivotNode:Node = arrToSort[pivot];
		var tempNode:Node;
		var less:Array<Node> = new Array<Node>();
		var more:Array<Node> = new Array<Node>();
		for (i in 0...arrToSort.length)
		{
			if (i != pivot)
			{
				tempNode = arrToSort[i];
				if (CompareConditon(pivotNode, tempNode, horizontal))
				{
					less.push(tempNode);
				}
				else 
				{
					more.push(tempNode);
				}
			}
		}
		arrToSort = null;
		return ConcatenateArr(QuickSortNodes(less, horizontal), pivotNode, QuickSortNodes(more, horizontal));
	}
	
	private static function CompareConditon(actualNode:Node, tocompare:Node, horizontal:Bool):Bool 
	{
		if (horizontal) 
		{
			var result:Bool = tocompare.Tj < actualNode.Tj;
			return result;
		}
		else 
		{
			var result:Bool = tocompare.Ti < actualNode.Ti;
			return result;
		}
	}				
	
	private static function ConcatenateArr(less:Array<Node>, value:Node, more:Array<Node>):Array<Node> 
	{
		var result:Array<Node> = new Array<Node>();
		var i:Int = 0;
		var lessval:Int = less.length;
		var moreval:Int = more.length;
		for (i in 0...lessval) 
		{
			result.push(less[i]);
		}
		result .push(value);
		for (i in 0...moreval) 
		{
			result.push(more[i]);
		}
		less = null;
		more = null;
		return result;			
	}
	
	/**
	 * Destroys this element, freeing memeory.
	 */
	public function destroy():Void 
	{
		var i:Float;
		var j:Float;
		for (i in 0...maxRows) 
		{
			for (j in 0...maxCols) 
			{
				topography[i * maxCols + j] = null;
				geography[i * maxCols + j] = null;
			}
			
		}
		var numNodes:Int = nodes.length;
		for (i in 0...numNodes) 
		{
			nodes[i].destroy();
		}
		
		nodes = null;
		nodesObject = null;
	}
}