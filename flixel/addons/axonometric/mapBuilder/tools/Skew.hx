package flixel.addons.axonometric.mapBuilder.tools;

import flash.geom.Matrix;
import flash.display.BitmapData;
import flash.display.Graphics;

/**
 * The skew class can skew bitmaps to 4 given points, it also provides multiple methods of improving the distortion quality
 * @license Creative Commons by-nc-sa
 * @author Maxim Sprey
 * @version 1.0
 */
class Skew 
{
	public var smooth:Bool;
	public var RP:Bool;
	private var UVarray:Array<Dynamic>;
	private var XYarray:Array<Dynamic>;
	public var debug:Bool;
	
	public function new (Smoothing:Bool, db:Bool):Void 
	{
		smooth = Smoothing;
		debug = db;
		UVarray = [];
		XYarray = [];
	}
	
	public function AASkew(pa:Array<Dynamic>, pb:Array<Dynamic>, pc:Array<Dynamic>, pd:Array<Dynamic>, bd:BitmapData, cont:Dynamic, AAh:Int, AAv:Int):Void 
	{
		// Create an AA*AA grid of squares
		UVMap(bd.width,bd.height,AAh,AAv);
		XYMap(pa,pb,pc,pd,bd.width,bd.height,AAh,AAv);
		for (i in 0...AAh) 
		{
			for (j in 0...AAv) 
			{
				var a:Array<Dynamic> = [XYarray[j][i][0], XYarray[j][i][1]];
				var b:Array<Dynamic> = [XYarray[j + 1][i][0], XYarray[j + 1][i][1]];
				var c:Array<Dynamic> = [XYarray[j + 1][i + 1][0], XYarray[j + 1][i + 1][1]];
				var d:Array<Dynamic> = [XYarray[j][i + 1][0], XYarray[j][i + 1][1]];
				if (debug)
				{
					cont.graphics.lineStyle(2, 0xff0000, 1);
				}
				else
				{
					cont.graphics.lineStyle(0, 0, 0);
				}
				AAtransformer(a, b, c, d, i, j, bd, cont, AAh, AAv);
			}
		}
	}
	
	private function UVMap(w:Float, h:Float, AAh:Int, AAv:Int):Void 
	{
		var hS:Float = w / AAh;
		var vS:Float = h / AAv;
		for (i in 0...AAh)
		{
			UVarray[i] = [];
			for (j in 0...AAv)
			{
				UVarray[i][j] = [(i * hS), (j * vS)];
			}
		}
	}
	
	private function XYMap(pa:Array<Dynamic>, pb:Array<Dynamic>, pc:Array<Dynamic>, pd:Array<Dynamic>, w:Float, h:Float, AAh:Int, AAv:Int):Void 
	{
		var lVec:Array<Dynamic> = [pc[0] - pa[0], pc[1] - pa[1]];
		var rVec:Array<Dynamic> = [pd[0] - pb[0], pd[1] - pb[1]];
		var p:Array<Dynamic> = [];
		var pL:Array<Dynamic> = [];
		var pR:Array<Dynamic> = [];
		var xc:Float;
		var yc:Float;
		for (i in 0...AAh)
		{
			XYarray[i] = [];
			for (j in 0...AAh)
			{
				p = UVarray[i][j];
				XYarray[i][j] = [];
				xc = p[0] / w;
				yc = p[1] / h;
				pL[0] = pa[0] + (yc * lVec[0]);
				pL[1] = pa[1] + (yc * lVec[1]);
				pR[0] = pb[0] + (yc * rVec[0]);
				pR[1] = pb[1] + (yc * rVec[1]);
				XYarray[i][j][0] = pL[0] + (pR[0] - pL[0]) * xc;
				XYarray[i][j][1] = pL[1] + (pR[1] - pL[1]) * xc;
			}
		}
	}
	
	public function AAtransformer(pa:Array<Dynamic>, pb:Array<Dynamic>, pc:Array<Dynamic>, pd:Array<Dynamic>, i:Int, j:Int, bd:BitmapData, cont:Dynamic, AAh:Int, AAv:Int):Void 
	{
		var bW:Int = bd.width;
		var bH:Int = bd.height;
		var inMat:Matrix = new Matrix();
		var outMat:Matrix = new Matrix();
		var ia:Array<Dynamic> = [UVarray[j][i][0], UVarray[j][i][1]];
		var ib:Array<Dynamic> = [UVarray[j + 1][i][0], UVarray[j + 1][i][1]];
		var ic:Array<Dynamic> = [UVarray[j + 1][i + 1][0], UVarray[j + 1][i + 1][1]];
		var id:Array<Dynamic> = [UVarray[j][i + 1][0], UVarray[j][i + 1][1]];
		inMat.a = (ib[0] - ia[0]) / bW;
		inMat.b = (ib[1] - ia[1]) / bW;
		inMat.c = (id[0] - ia[0]) / bH;
		inMat.d = (id[1] - ia[1]) / bH;
		inMat.tx = ia[0];
		inMat.ty = ia[1];
		outMat.a = ((pb[0] - pa[0]) / bW);
		outMat.b = (pb[1] - pa[1]) / bW;
		outMat.c = (pd[0] - pa[0]) / bH;
		outMat.d = ((pd[1] - pa[1]) / bH);
		outMat.tx = pa[0];
		outMat.ty = pa[1];
		inMat.invert();
		inMat.concat(outMat);

		cont.graphics.beginBitmapFill(bd, inMat, true, smooth);
		cont.graphics.moveTo(pa[0], pa[1]);
		cont.graphics.lineTo(pb[0], pb[1]);
		cont.graphics.lineTo(pd[0], pd[1]);
		cont.graphics.lineTo(pa[0], pa[1]);
		cont.graphics.endFill();
		
		inMat.a = (ic[0] - id[0]) / bW;
		inMat.b = (ic[1] - id[1]) / bW;
		inMat.c = (ic[0] - ib[0]) / bH;
		inMat.d = (ic[1] - ib[1]) / bH;
		inMat.tx = id[0];
		inMat.ty = id[1];
		outMat.a = ((pc[0] - pd[0]) / bW);
		outMat.b = (pc[1] - pd[1]) / bW;
		outMat.c = (pc[0] - pb[0]) / bH;
		outMat.d = ((pc[1] - pb[1]) / bH);
		outMat.tx = pd[0];
		outMat.ty = pd[1];
		inMat.invert();
		inMat.concat(outMat);

		cont.graphics.beginBitmapFill(bd, inMat, true, smooth);
		cont.graphics.moveTo(pc[0], pc[1]);
		cont.graphics.lineTo(pd[0], pd[1]);
		cont.graphics.lineTo(pb[0], pb[1]);
		cont.graphics.lineTo(pc[0], pc[1]);
		cont.graphics.endFill();
	}
	
	public function transformer(pa:Array<Dynamic>, pb:Array<Dynamic>, pc:Array<Dynamic>, pd:Array<Dynamic>, bd:BitmapData, cont:Dynamic, AAh:Int, AAv:Int):Void 
	{
		var bW:Int = bd.width;
		var bH:Int = bd.height;
		var inMat:Matrix = new Matrix();
		var outMat:Matrix = new Matrix();
		outMat.a = ((pb[0] - pa[0]) / bW);
		outMat.b = (pb[1] - pa[1]) / bW;
		outMat.c = (pd[0] - pa[0]) / bH;
		outMat.d = ((pd[1] - pa[1]) / bH);
		outMat.tx = pa[0];
		outMat.ty = pa[1];

		cont.graphics.beginBitmapFill(bd, outMat, true, smooth);
		cont.graphics.moveTo(pa[0], pa[1]);
		cont.graphics.lineTo(pb[0], pb[1]);
		cont.graphics.lineTo(pd[0], pd[1]);
		cont.graphics.lineTo(pa[0], pa[1]);
		cont.graphics.endFill();
		
		outMat.a = ((pc[0] - pd[0]) / bW);
		outMat.b = (pc[1] - pd[1]) / bW;
		outMat.c = (pc[0] - pb[0]) / bH;
		outMat.d = ((pc[1] - pb[1]) / bH);
		outMat.tx = pd[0];
		outMat.ty = pd[1];

		cont.graphics.beginBitmapFill(bd, outMat, true, smooth);
		cont.graphics.moveTo(pc[0], pc[1]);
		cont.graphics.lineTo(pd[0], pd[1]);
		cont.graphics.lineTo(pb[0], pb[1]);
		cont.graphics.lineTo(pc[0], pc[1]);
		cont.graphics.endFill();
	}
}