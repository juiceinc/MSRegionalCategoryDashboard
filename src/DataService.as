package
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	
	import org.juicekit.util.Sort;

	public class DataService
	{	
		[Bindable] public static var data:ArrayCollection = new ArrayCollection();
		
		//Constructor
		public function DataService()
		{
			
		}
		
		public static function fetch():void
		{
			var xmlUrl:URLRequest = new URLRequest('data/region_category_analysis.xml');
			var loader:URLLoader = new URLLoader(xmlUrl);
			loader.addEventListener(Event.COMPLETE, loaderCompleteHandler);
		}
		
		private static function loaderCompleteHandler(e:Event):void
		{
			var xml:XML = XML(URLLoader(e.target).data);
			
			/*
			* regions = ['Central', 'Mid-Atlantic', ...]
			* categories = ['Books', 'Electronics', 'Movies', 'Music']
			* subcategories = ['Business', ...]
			* o = {'region':,
				    'category':,
					'subcategory':,
					'revenue':
					'percentGrowth':
					...
				}
			*/
			
			var regions:Array = new Array();
			var categories:Array = new Array();
			var subcategories:Array = new Array();
			var o:Object = {};
			var fm:XML;
			
			for each (var template:XML in xml.template)
			{
				if (template.@nodekey == 'W101')
				{
					
					for each (var unode:XML in template.us.u)
					{
						//categories
						if (unode.@i == 0 && unode.@t == 1)
						{
							for each (fm in unode.at.es.e.fm)
							{
								if (fm.@i == 1)
								{
									o = {};
									o.category = fm.@fv;
									o.subcategories = new Array();
									trace(o.category);
									categories.push(o);
								}
							}
							trace('-------');
							trace(categories[0].category);
							trace(categories[1].category);
							trace('---------');
						}
						//subcategories
						else if (unode.@i == 1 && unode.@t == 1)
						{
							for each (fm in unode.at.es.e.fm)
							{
								if (fm.@i == 0)
								{
									var index:int = int( fm.@fv.substr(0,1) );
									subcategories = categories[index-1].subcategories;
									trace(index);
									trace(categories[index-1].category);
									trace(subcategories);
								}
								if (fm.@i == 1)
									subcategories.push(fm.@fv);
							}
						}
						//regions
						else if (unode.@i == 2 && unode.@t == 1)
						{
							for each (fm in unode.at.es.e.fm)
							{
								if (fm.@i == 1)
									regions.push(fm.@fv);
							}
						}
						
					}
					
					//data
					var costData:Array = new Array;
					for each (var cnode:XML in template.gb.xv.cs.c)
					{
						costData.push(Number(cnode.@mv));
					}
					trace(costData);
					
					var results:Array = new Array();
					var i:int = 0;
					regions.sort();
					
					for each (var region:String in regions)
					{
						trace('region: ' , region);
						for each (var cat:Object in categories)
						{
							trace('category: ', cat.category);
							for each (var subcat:String in cat.subcategories)
							{
								o = {};
								o.region = region;
								o.category = cat.category;
								
								o.subcategory = subcat;
								o.revenue = costData[i];
								o.percentGrowth = costData[++i];
								o.profitMargin = costData[++i];
								o.percentDiscount = costData[++i];
								o.avgRevenue = costData[++i];
								i++;
								results.push(o);
							}
						}
					}
					trace('** Results **');
					trace(results);
					
					
				} //template W101
				
			}
			
			trace(categories);
			trace(subcategories);
			
//			var s:Sort = new Sort(['region', 'category']);
//			s.sort(results);
			
			data = new ArrayCollection(results);
		}
	}
}