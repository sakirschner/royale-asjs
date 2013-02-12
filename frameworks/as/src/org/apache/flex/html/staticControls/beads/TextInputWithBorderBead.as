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
package org.apache.flex.html.staticControls.beads
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import org.apache.flex.core.IStrand;
	import org.apache.flex.core.UIBase;
	import org.apache.flex.html.staticControls.beads.models.SingleLineBorderModel;
	import org.apache.flex.html.staticControls.supportClasses.Border;

	public class TextInputWithBorderBead extends TextInputBead
	{
		public function TextInputWithBorderBead()
		{
			super();
		}
		
		private var _border:Border;
		
		public function get border():Border
		{
			return _border;
		}
		
		override public function set strand(value:IStrand):void
		{
			super.strand = value;
			
			// add a border to this
			_border = new Border();
			border.addToParent(UIBase(strand));
			_border.model = new SingleLineBorderModel();
			_border.addBead(new SingleLineBorderBead());
			
			IEventDispatcher(strand).addEventListener("widthChanged", sizeChangedHandler);
			IEventDispatcher(strand).addEventListener("heightChanged", sizeChangedHandler);
			sizeChangedHandler(null);
		}
		
		private function sizeChangedHandler(event:Event):void
		{
			var ww:Number = DisplayObject(strand).width;
			_border.width = ww;
			
			var hh:Number = DisplayObject(strand).height;
			_border.height = hh;
		}
	}
}