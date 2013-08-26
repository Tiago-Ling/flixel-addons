package flixel.addons.axonometric ;
import flixel.addons.axonometric.mapBuilder.tools.BlockDescriptor;	
import flixel.addons.axonometric.mapBuilder.AxoMap;
import flash.geom.Point;
import flash.display.BitmapData;
import openfl.Assets;


/**
 * The factory method of the library, given a block descriptor, and a creation method, creates objets of the class AxoMap
 * 
 * @author	AS3 Original: Miguel Ángel Piedras Carrillo; 
 * 			Original Haxe 2.10 Port: Masadow
 * 			Second Haxe Port: Tiago Ling Alexandre
 */	

class AxonometricMapFactory
{				
	private var blockDescriptor:BlockDescriptor;
	
	public function new(floorTile:BitmapData, wallTileA:BitmapData, wallTileB:BitmapData, width:Int, height:Int, depth:Int)
	{
		SetBlockDescriptor(width, height, depth, floorTile, wallTileA, wallTileB);
	}
	
	/**
	 * Sets a descriptor to have more control over the shape and texture of the ground, the ratios of the images must be accurate in order to this to work propertly. If it's not defined
	 * the library will use a default descriptor.
	 * 
	 * @param	BlockWidth				The width of 1 block.
	 * @param	BlockHeight				The height of 1 block.
	 * @param	BlockDepth				The depth of 1 block.
	 * @param	TilemapWidthDepth		The image the ground tilemap uses, its width must be a multiple of BlockWidth and its height a multiple of BlockDepth.
	 * @param	TilemapWidthHeight		The image the right side of the block uses, its widht must be a multiple of BlockWidth and its height must be a multiple of BlockHeight.
	 * @param	TilemapDepthHeight		The image the left side of the block uses its width must be a multple of BlockDepth and its height must be a multiple of BlockHeight.
	 * 
	 */				
	public function SetBlockDescriptor(BlockWidth:Int, BlockHeight:Int, BlockDepth:Int, TilemapWidthDepth:BitmapData, TilemapWidthHeight:BitmapData, TilemapDepthHeight:BitmapData):Void 
	{
		blockDescriptor = new BlockDescriptor(BlockWidth, BlockHeight, BlockDepth, TilemapWidthDepth, TilemapWidthHeight, TilemapDepthHeight);
	}

	/**
	 * Creates the map with a trimetric shape. Returns null if any parameter is invalid.
	 * 
	 * @param	x						x coodrinate of the center of the map.
	 * @param	y						y coodrinate of the center of the map.
	 * @param	theta					Angle measured in radians, it defines the shape of the plane yx(for correct functionality , theta+phi must form an angle bigger thanPI).
	 * @param	phi						Angle measured in radians, it defines the shape of the plane xz(for correct functionality , theta+phi must form an angle bigger than PI).
	 * @param	leftsided				Sets the floor with a left inclination.
	 * @param	debug					Sets the debugging mode.
	 */						
	public function SetAsTrimetric(x:Float, y:Float, theta:Float, phi:Float, leftsided:Bool = false, debug:Bool = false):AxoMap 
	{			
		try
		{
			theta=Math.abs(theta);
			phi=Math.abs(phi);
			if (leftsided)
			{			
				return CreateMap(x, y, theta,  phi, debug);
			}
			else 
			{
				return CreateMap(x, y, -theta, -phi, debug);
			}
		}
		catch (errObject:Dynamic)
		{
			
		}
		return null;
	}
			
	/**
	 * Creates the map with a dimetric shape. Returns null if any parameter is invalid.
	 * 
	 * @param	x						x coodrinate of the center of the map.
	 * @param	y						y coodrinate of the center of the map.
	 * @param	theta					Angle measured in radians, it defines the shape of the plane yx and yz(for correct functionality , theta must form an angle bigger than PI/2)
	 * @param	leftsided				Sets the floor with a left inclination.
	 * @param	debug					Sets the debugging mode.
	 */								
	public function SetAsDimetric(x:Float, y:Float, theta:Float, leftsided:Bool = false, debug:Bool = false):AxoMap 
	{			
		try
		{
			theta = Math.abs(theta);

			if (leftsided)
			{			
				return CreateMap(x, y, theta, (2*Math.PI-2*theta), debug);
			}
			else 
			{
				return CreateMap(x, y, -theta, -(2*Math.PI-2*theta), debug);
			}
		}
		catch (errObject:Dynamic)
		{
		
		}
		return null;
	}
	
	/**
	 * Creates the map with an isometric shape. Returns null if any parameter is invalid.
	 * 
	 * @param	x						x coodrinate of the center of the map.
	 * @param	y						y coodrinate of the center of the map.
	 * @param	leftsided				Sets the floor with a left inclination.
	 * @param	debug					Sets the debugging mode.
	 */								
	public function SetAsIsometric(x:Float, y:Float, leftsided:Bool = false, debug:Bool = false):AxoMap 
	{
		try
		{
			if (leftsided)
			{
				return CreateMap(x, y, 2*Math.PI/3, 2*Math.PI/3, debug);
			}
			else 
			{
				return CreateMap(x, y, -2*Math.PI/3, -2*Math.PI/3, debug);
			}			
		}
		catch (errObject:Dynamic)
		{	
			
		}
		return null;
	}
	
	/**
	 * Creates an oblique map on the yx plane. Returns null if any parameter is invalid.
	 * 
	 * @param	x						x coodrinate of the center of the map.
	 * @param	y						y coodrinate of the center of the map.
	 * @param	phi						Angle measured in radians, it defines the shape of the plane xz(for correct functionality phi must form a bigger angle than PI/2)
	 * @param	leftsided				Sets the floor with a left inclination.
	 * @param	debug					Sets the debugging mode.
	 */								
	public function SetAsObliqueYX(x:Float, y:Float, phi:Float, leftsided:Bool = false, debug:Bool = false):AxoMap 
	{
		try
		{
			phi=Math.abs(phi);
			if (leftsided)
			{			
				return CreateMap(x, y, Math.PI/2, phi, debug);
			}
			else 
			{
				return CreateMap(x, y, -Math.PI/2, -phi, debug);
			}
		}
		catch (errObject:Dynamic) 
		{
			
		}
		return null;
	}
	
	/**
	 * Creates an oblique map on the xz plane. Returns null if any parameter is invalid.
	 * 
	 * @param	x						x coodrinate of the center of the map.
	 * @param	y						y coodrinate of the center of the map.
	 * @param	theta					Angle measured in radians, it defines the shape of the plane yx(for correct functionality theta must form a bigger angle than PI/2)
	 * @param	leftsided				Sets the floor with a left inclination.
	 * @param	debug					Sets the debugging mode.
	 */
	public function SetAsObliqueXZ(x:Float, y:Float, theta:Float, leftsided:Bool = false, debug:Bool = false):AxoMap 
	{
		try
		{
			theta = Math.abs(theta);
			if (leftsided)
			{
				return CreateMap(x, y,  theta,  Math.PI/2 , debug);
			}
			else
			{
				return CreateMap(x ,y, -theta, -Math.PI/2 , debug);
			}
		}
		catch (errObject:Dynamic)
		{
			
		}
		return null;
	}
	
	/**
	 * Creates an oblique map on the zy plane. Returns null if any parameter is invalid.
	 *
	 * @param	x						x coodrinate of the center of the map.
	 * @param	y						y coodrinate of the center of the map.
	 * @param	theta					Angle measured in radians, it defines the shape of the plane yx(for correct functionality theta must form a bigger angle than PI/2)
	 * @param	leftsided				Sets the floor with a left inclination.
	 * @param	debug					Sets the debugging mode.
	 */
	public function SetAsObliqueZY(x:Float, y:Float, theta:Float, leftsided:Bool = false, debug:Bool = false):AxoMap 
	{
		try
		{
			theta=Math.abs(theta);			
			if (leftsided)
			{			
				return CreateMap(x, y, theta,(2*Math.PI-theta-Math.PI/2), debug);
			}
			else
			{
				return CreateMap(x, y, -theta, -(2*Math.PI-theta-Math.PI/2), debug);
			}
		}
		catch (errObject:Dynamic)
		{
			
		}
		return null;
	}

	private function CreateMap(x:Float, y:Float, theta:Float, phi:Float, debug:Bool = false):AxoMap 
	{			
		return new AxoMap(x, y, theta, phi, blockDescriptor, debug);
	}


}