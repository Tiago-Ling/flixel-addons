package flixel.addons.editors.spine.texture;

import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.Assets;
import openfl.display.BitmapData;
import spinehaxe.atlas.AtlasPage;
import spinehaxe.atlas.AtlasRegion;
import spinehaxe.atlas.Texture;
import spinehaxe.atlas.TextureLoader;

class FlixelTextureLoader implements TextureLoader
{
	//private var path:String;
	private var path:FlxGraphicAsset;
	
	private var secPage:BitmapData;
	
	//public function new(path:String) 
	public function new(path:FlxGraphicAsset, ?secPage:BitmapData) 
	{
		this.path = path;
		this.secPage = secPage;
	}
	
	public function loadTexture(textureFile:String, format, useMipMaps):Texture 
	{
		return new FlixelTexture(path + textureFile);
	}
	
	public function loadPage(page:AtlasPage, path:String):Void 
	{
/*		var bitmapData:BitmapData = Assets.getBitmapData(this.path + path);
		if (bitmapData == null)
			throw ("BitmapData not found with name: " + this.path + path);
		page.rendererObject = bitmapData;
		page.width = bitmapData.width;
		page.height = bitmapData.height;*/
		
		if (page.name.indexOf('2.png') > -1) {
			page.rendererObject = secPage;
			page.width = secPage.width;
			page.height = secPage.height;
			
			return;
		}
		
		if (Std.is(this.path, BitmapData)) {
			var bd = cast(this.path, BitmapData);
			page.rendererObject = bd;
			page.width = bd.width;
			page.height = bd.height;
		} else {
			var bitmapData:BitmapData = Assets.getBitmapData(this.path + path);
			if (bitmapData == null)
				throw ("BitmapData not found with name: " + this.path + path);
			page.rendererObject = bitmapData;
			page.width = bitmapData.width;
			page.height = bitmapData.height;
		}
	}

	public function loadRegion(region:AtlasRegion):Void {  }

	public function unloadPage(page:AtlasPage):Void 
	{
		cast(page.rendererObject, BitmapData).dispose();
		page.rendererObject = null;
		page = null;
	}
}
