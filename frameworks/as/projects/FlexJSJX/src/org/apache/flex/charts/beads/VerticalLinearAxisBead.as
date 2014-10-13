////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package org.apache.flex.charts.beads
{
	import org.apache.flex.charts.core.IChart;
	import org.apache.flex.charts.core.IHorizontalAxisBead;
	import org.apache.flex.charts.core.IVerticalAxisBead;
	import org.apache.flex.core.IBead;
	import org.apache.flex.core.ISelectionModel;
	import org.apache.flex.core.IStrand;
	import org.apache.flex.core.UIBase;
	import org.apache.flex.core.graphics.Path;
	import org.apache.flex.events.Event;
	import org.apache.flex.events.IEventDispatcher;
	import org.apache.flex.html.Label;
	import org.apache.flex.html.beads.models.ArraySelectionModel;
	
	/**
	 *  The VerticalLinearAxisBead class provides a vertical axis that uses a numeric
	 *  range. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @playerversion AIR 2.6
	 *  @productversion FlexJS 0.0
	 */
	public class VerticalLinearAxisBead extends AxisBaseBead implements IBead, IVerticalAxisBead
	{
		public function VerticalLinearAxisBead()
		{
			super();
			
			placement = "left";
		}
				
		/**
		 *  @copy org.apache.flex.core.IBead#strand
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion FlexJS 0.0
		 */
		override public function set strand(value:IStrand):void
		{
			super.strand = value;
			
			// in order to draw or create the labels, need to know when the series has been created.
			IEventDispatcher(strand).addEventListener("layoutComplete",handleItemsCreated);
		}
		
		private var _axisWidth:Number = 50;
		
		public function get axisWidth():Number
		{
			return _axisWidth;
		}
		public function set axisWidth(value:Number):void
		{
			_axisWidth = value;
		}
		
		private var _valueField:String;
		
		/**
		 *  The name of field within the chart data the holds the value being mapped
		 *  to this axis. If values should fall within minValue and maxValue but if
		 *  not, they will be fixed to the closest value.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion FlexJS 0.0
		 */
		public function get valueField():String
		{
			return _valueField;
		}
		public function set valueField(value:String):void
		{
			_valueField = value;
		}
		
		private var _minValue:Number = Number.NaN;
		
		/**
		 *  The minimun value to be represented on this axis. If minValue is NaN,
		 *  the value is calculated from the data.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion FlexJS 0.0
		 */
		public function get minValue():Number
		{
			return _minValue;
		}
		public function set minValue(value:Number):void
		{
			_minValue = value;
		}
		
		private var _maxValue:Number = Number.NaN;
		
		/**
		 *  The maximum value to be represented on this axis. If maxValue is NaN,
		 *  the value is calculated from the data.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion FlexJS 0.0
		 */
		public function get maxValue():Number
		{
			return _maxValue;
		}
		public function set maxValue(value:Number):void
		{
			_maxValue = value;
		}
		
		/**
		 * @private
		 */
		private function formatLabel(n:Number):String
		{
			var sign:Number = n < 0 ? -1 : 1;
			n = Math.abs(n);
			
			var i:int;
			
			if (0 <= n && n <= 1) {
				i = Math.round(n * 100);
				n = i / 100.0;
			}
			else {
				i = Math.round(n);
				n = i;
			}
			
			var result:String = String(sign*n);
			return result;
		}
		
		/**
		 * @private
		 */
		private function handleItemsCreated(event:Event):void
		{
			var model:ArraySelectionModel = strand.getBeadByType(ISelectionModel) as ArraySelectionModel;
			var items:Array;
			if (model.dataProvider is Array) items = model.dataProvider as Array;
			else return;
			
			var series:Array = IChart(strand).series;
			
			var xAxis:IHorizontalAxisBead;
			if (strand.getBeadByType(IHorizontalAxisBead)) xAxis = strand.getBeadByType(IHorizontalAxisBead) as IHorizontalAxisBead;
			var xAxisOffset:Number = xAxis == null ? 0 : xAxis.axisHeight;
			
			var yAxisWidthOffset:Number = axisWidth;
			var useHeight:Number = UIBase(strand).height-xAxisOffset;
			var xpos:Number = yAxisWidthOffset;
			var ypos:Number = useHeight;
			var originX:Number = yAxisWidthOffset;
			var originY:Number = 0;
			
			// determine minimum and maximum values, if needed
			if (isNaN(minValue)) {
				minValue = Number.MAX_VALUE;
				for(var i:int=0; i < items.length; i++) {
					var value:Number = Number(items[i][valueField]);
					if (!isNaN(value)) minValue = Math.min(minValue,value);
					else minValue = Math.min(minValue,0);
				}
			}
			if (isNaN(maxValue)) {
				maxValue = Number.MIN_VALUE;
				for(i=0; i < items.length; i++) {
					value = Number(items[i][valueField]);
					if (!isNaN(value)) maxValue = Math.max(maxValue,value);
					else maxValue = Math.max(maxValue,0);
				}
			}
			
			var numTicks:Number = 10; // should determine this some other way, I think
			var tickStep:Number = (maxValue - minValue)/numTicks;
			var tickSpacing:Number = useHeight/numTicks;
			var tickValue:Number = minValue;
			
			// adjust ypos to the first tick position
			ypos = useHeight;// - tickSpacing;
			
			// place the labels below the axis enough to account for the tick marks
			var labelY:Number = UIBase(strand).height + 8;
			
			for(i=0; i < numTicks+1; i++) {				
				var label:Label = new Label();
				label.text = formatLabel(tickValue);
				label.x = 0;
				label.y = ypos - label.height/2;
				UIBase(strand).addElement(label);
			
				// add a tick mark, too.
				addTickMark(xpos - 5 - originX, ypos - originY, 5, 0);
				
				ypos -= tickSpacing;
				tickValue += tickStep;
			}
			
			// draw the axis and the tick marks
			drawAxisPath(originX, originY, 0, useHeight);
			drawTickPath(originX, originY);
			
		}
		
	}
}