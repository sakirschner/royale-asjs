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
package org.apache.royale.jewel.beads.itemRenderers
{
    import org.apache.royale.core.IChild;
    import org.apache.royale.core.IDataProviderItemRendererMapper;
    import org.apache.royale.core.IIndexedItemRenderer;
    import org.apache.royale.core.IIndexedItemRendererInitializer;
    import org.apache.royale.core.ILabelFieldItemRenderer;
    import org.apache.royale.core.IParent;
    import org.apache.royale.core.UIBase;
    import org.apache.royale.events.Event;
    import org.apache.royale.events.IEventDispatcher;
    import org.apache.royale.html.beads.DataItemRendererFactoryBase;
    import org.apache.royale.html.beads.IListView;
    import org.apache.royale.html.supportClasses.StyledDataItemRenderer;
    import org.apache.royale.jewel.Label;
    import org.apache.royale.jewel.Table;
    import org.apache.royale.jewel.beads.controls.TextAlign;
    import org.apache.royale.jewel.beads.models.TableModel;
    import org.apache.royale.jewel.beads.views.TableView;
    import org.apache.royale.jewel.itemRenderers.TableItemRenderer;
    import org.apache.royale.jewel.supportClasses.list.IListPresentationModel;
    import org.apache.royale.jewel.supportClasses.table.TBodyContentArea;
    import org.apache.royale.jewel.supportClasses.table.THead;
    import org.apache.royale.jewel.supportClasses.table.TableColumn;
    import org.apache.royale.jewel.supportClasses.table.TableHeaderCell;
    import org.apache.royale.jewel.supportClasses.table.TableRow;

    /**
	 * This class creates itemRenderer instances from the data contained within an ICollectionView
     * and generates the appropiate table structure with thead, tbody and table rows and cells
     * to hold the columns and data in cells.
	 */
	public class TableItemRendererFactoryForCollectionView extends DataItemRendererFactoryBase implements IDataProviderItemRendererMapper
	{
		public function TableItemRendererFactoryForCollectionView(target:Object = null)
		{
			super(target);
		}
		
		protected var labelField:String;

        protected var view:TableView;
        protected var model:TableModel;
        protected var table:Table;

		private var tbody:TBodyContentArea;

        /**
		 * @private
		 * @royaleignorecoercion org.apache.royale.collections.ICollectionView
		 * @royaleignorecoercion org.apache.royale.jewel.supportClasses.list.IListPresentationModel
		 * @royaleignorecoercion org.apache.royale.core.IIndexedItemRenderer
		 * @royaleignorecoercion org.apache.royale.events.IEventDispatcher
		 */
		override protected function dataProviderChangeHandler(event:Event):void
		{
			view = _strand.getBeadByType(IListView) as TableView;
			tbody = view.dataGroup as TBodyContentArea;
            table = _strand as Table;
			model = dataProviderModel as TableModel;
			
			// -- 1) CLEANING PHASE
            if (!model)
				return;
			if (!model.dataProvider)
			{
				model.selectedIndex = -1;
				model.selectedItem = null;
				model.selectedItemProperty = null;

				// TBodyContentArea - remove data items
				removeAllItemRenderers(tbody);
				return;
			}
			// remove this and better add beads when needed
			// listen for individual items being added in the future.
			// var dped:IEventDispatcher = dp as IEventDispatcher;
			// dped.addEventListener(CollectionEvent.ITEM_ADDED, itemAddedHandler);
			// dped.addEventListener(CollectionEvent.ITEM_REMOVED, itemRemovedHandler);
			// dped.addEventListener(CollectionEvent.ITEM_UPDATED, itemUpdatedHandler);
			
            // TBodyContentArea - remove data items
			removeAllItemRenderers(tbody);
			
            // THEAD - remove header items
			removeElements(view.thead);

			if(!model.columns)
				return;
			
            // -- add the header
            createHeader();
			
			// -- 2) CREATION PHASE
			var presentationModel:IListPresentationModel = _strand.getBeadByType(IListPresentationModel) as IListPresentationModel;
			labelField = model.labelField;
			
            var column:TableColumn;
            var ir:TableItemRenderer;

			var n:int = model.dataProvider.length;
			var index:int = 0;
			for (var i:int = 0; i < n; i++)
			{
			    for(var j:int = 0; j < model.columns.length; j++)
				{
			        column = model.columns[j] as TableColumn;
					
			        if(column.itemRenderer != null)
                    {
						ir = column.itemRenderer.newInstance() as TableItemRenderer;
                    } else
                    {
                        ir = itemRendererFactory.createItemRenderer() as TableItemRenderer;
                    }

					labelField =  column.dataField;
                    var data:Object = model.dataProvider.getItemAt(i);

                    (ir as StyledDataItemRenderer).dataField = labelField;
					(ir as StyledDataItemRenderer).rowIndex = i;
					(ir as StyledDataItemRenderer).columnIndex = j;
					
					(itemRendererInitializer as IIndexedItemRendererInitializer).initializeIndexedItemRenderer(ir, data, index);
                    
					tbody.addItemRendererAt(ir, index);
					ir.labelField = labelField;
					
					if (presentationModel) {
						UIBase(ir).height = presentationModel.rowHeight;
					}

					ir.index = index;
					ir.data = data;

                    if(column.align != "")
                    {
                        ir.align = column.align;
                    }

					index++;
                }
			}
			
			IEventDispatcher(_strand).dispatchEvent(new Event("itemsCreated"));
            table.dispatchEvent(new Event("layoutNeeded"));
        }

		public function removeElements(container: IParent):void
		{
			if(container != null)
			{
				while (container.numElements > 0) {
					var child:IChild = container.getElementAt(0);
					container.removeElement(child);
				}
			}
		}

        private function createHeader():void
		{
            var createHeaderRow:Boolean = false;
            var test:TableColumn;
            var c:int;

			for(c=0; c < model.columns.length; c++)
			{
				test = model.columns[c] as TableColumn;
				if (test.label != null) {
					createHeaderRow = true;
					break;
				}
			}

            if (createHeaderRow) 
            {
				if(view.thead == null)
                	view.thead = new THead();
				var thead:THead = view.thead;
				var headerRow:TableRow = new TableRow();
				
				for(c=0; c < model.columns.length; c++)
				{
					test = model.columns[c] as TableColumn;
					var tableHeader:TableHeaderCell = new TableHeaderCell();
					
                    var label:Label = new Label();
					tableHeader.addElement(label);
					label.text = test.label == null ? "" : test.label;
					
					var columnLabelTextAlign:TextAlign = new TextAlign();
					columnLabelTextAlign.align = test.columnLabelAlign;
					label.addBead(columnLabelTextAlign);
					headerRow.addElement(tableHeader);
				}

				thead.addElement(headerRow);
				table.addElementAt(thead,0);
			}
        }

		/**
		 * @private
		 * @royaleignorecoercion org.apache.royale.collections.ICollectionView
		 * @royaleignorecoercion org.apache.royale.jewel.supportClasses.list.IListPresentationModel
		 * @royaleignorecoercion org.apache.royale.core.IIndexedItemRenderer
		 * @royaleignorecoercion org.apache.royale.events.IEventDispatcher
		 */
		// protected function itemAddedHandler(event:CollectionEvent):void
		// {
		// }

		/**
		 * @private
		 * @royaleignorecoercion org.apache.royale.collections.ICollectionView
		 * @royaleignorecoercion org.apache.royale.jewel.supportClasses.list.IListPresentationModel
		 * @royaleignorecoercion org.apache.royale.core.IIndexedItemRenderer
		 * @royaleignorecoercion org.apache.royale.events.IEventDispatcher
		 */
		// protected function itemRemovedHandler(event:CollectionEvent):void
		// {
		// }

		/**
		 * @private
		 * @royaleignorecoercion org.apache.royale.collections.ICollectionView
		 * @royaleignorecoercion org.apache.royale.core.IIndexedItemRenderer
		 */
		// protected function itemUpdatedHandler(event:CollectionEvent):void
		// {
		// }
    }
}