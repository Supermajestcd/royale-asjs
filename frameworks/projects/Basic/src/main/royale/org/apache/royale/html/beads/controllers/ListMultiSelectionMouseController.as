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
package org.apache.royale.html.beads.controllers
{
	import org.apache.royale.core.IBeadController;
	import org.apache.royale.core.IItemRendererParent;
	import org.apache.royale.core.IRollOverModel;
	import org.apache.royale.core.ISelectableItemRenderer;
	import org.apache.royale.core.IMultiSelectionModel;
	import org.apache.royale.core.IStrand;
	import org.apache.royale.events.Event;
	import org.apache.royale.events.IEventDispatcher;
	import org.apache.royale.events.ItemAddedEvent;
	import org.apache.royale.events.ItemRemovedEvent;
	import org.apache.royale.events.MouseEvent;
	import org.apache.royale.html.beads.IListView;

	import org.apache.royale.events.ItemClickedEvent;

	/**
	 *  The ListMultiSelectionMouseController class is a controller for
	 *  org.apache.royale.html.List.  Controllers
	 *  watch for events from the interactive portions of a View and
	 *  update the data model or dispatch a semantic event.
	 *  This controller watches for events from the item renderers
	 *  and updates an IMultiSelectionModel (which supports multi
	 *  selection).      
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @playerversion AIR 2.6
	 *  @productversion Royale 0.9.7
	 */
	public class ListMultiSelectionMouseController implements IBeadController
	{
		/**
		 *  Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion Royale 0.9.7
		 */
		public function ListMultiSelectionMouseController()
		{
		}

		/**
		 *  The model.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion Royale 0.9.7
		 */
		protected var listModel:IMultiSelectionModel;

		/**
		 *  The view.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion Royale 0.9.7
		 */
		protected var listView:IListView;

		/**
		 *  The parent of the item renderers.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion Royale 0.9.7
		 */
		protected var dataGroup:IItemRendererParent;

		private var _strand:IStrand;

		/**
		 *  @copy org.apache.royale.core.IBead#strand
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion Royale 0.9.7
		 *  @royaleignorecoercion org.apache.royale.core.IMultiSelectionModel
		 *  @royaleignorecoercion org.apache.royale.events.IEventDispatcher
		 *  @royaleignorecoercion org.apache.royale.html.beads.IListView
		 */
		public function set strand(value:IStrand):void
		{
			_strand = value;
			listModel = value.getBeadByType(IMultiSelectionModel) as IMultiSelectionModel;
			listView = value.getBeadByType(IListView) as IListView;
			IEventDispatcher(_strand).addEventListener("itemAdded", handleItemAdded);
			IEventDispatcher(_strand).addEventListener("itemRemoved", handleItemRemoved);
		}

		/**
		 * @royaleignorecoercion org.apache.royale.events.IEventDispatcher
		 */
		protected function handleItemAdded(event:ItemAddedEvent):void
		{
			IEventDispatcher(event.item).addEventListener("itemClicked", selectedHandler);
			IEventDispatcher(event.item).addEventListener("itemRollOver", rolloverHandler);
			IEventDispatcher(event.item).addEventListener("itemRollOut", rolloutHandler);
		}

		/**
		 * @royaleignorecoercion org.apache.royale.events.IEventDispatcher
		 */
		protected function handleItemRemoved(event:ItemRemovedEvent):void
		{
			IEventDispatcher(event.item).removeEventListener("itemClicked", selectedHandler);
			IEventDispatcher(event.item).removeEventListener("itemRollOver", rolloverHandler);
			IEventDispatcher(event.item).removeEventListener("itemRollOut", rolloutHandler);
		}

		protected function selectedHandler(event:ItemClickedEvent):void
		{
			var selectedIndices:Array = [];
			if (!event.ctrlKey || !listModel.selectedIndices)
			{
				listModel.selectedIndices = [event.index];
			} else
			{
				// concat is so we have a new instance, avoiding code that might presume no change was made according to instance
				var indices:Array = listModel.selectedIndices.concat();
				var locationInSelectionList:int = indices.indexOf(event.index);
				if (locationInSelectionList < 0)
				{
					indices.push(event.index);
				} else
				{
					indices.removeAt(locationInSelectionList);
				}
				listModel.selectedIndices = indices;
			}
			listView.host.dispatchEvent(new Event("change"));
		}

		/**
		 * @royaleemitcoercion org.apache.royale.core.ISelectableItemRenderer
		 * @royaleignorecoercion org.apache.royale.core.IRollOverModel
		 */
		protected function rolloverHandler(event:Event):void
		{
			var renderer:ISelectableItemRenderer = event.currentTarget as ISelectableItemRenderer;
			if (renderer) {
				IRollOverModel(listModel).rollOverIndex = renderer.index;
			}
		}

		/**
		 * @royaleemitcoercion org.apache.royale.core.ISelectableItemRenderer
		 * @royaleignorecoercion org.apache.royale.core.IRollOverModel
		 */
		protected function rolloutHandler(event:Event):void
		{
			var renderer:ISelectableItemRenderer = event.currentTarget as ISelectableItemRenderer;
			if (renderer) {
				renderer.hovered = false;
				renderer.down = false;
				IRollOverModel(listModel).rollOverIndex = -1;
			}
		}

	}
}
