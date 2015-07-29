/**
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

goog.provide('org.apache.flex.html.beads.ContainerView');

goog.require('org.apache.flex.core.BeadViewBase');
goog.require('org.apache.flex.core.IBeadLayout');
goog.require('org.apache.flex.core.ILayoutParent');
goog.require('org.apache.flex.html.beads.models.ViewportModel');
goog.require('org.apache.flex.html.supportClasses.Viewport');



/**
 * @constructor
 * @extends {org.apache.flex.core.BeadViewBase}
 */
org.apache.flex.html.beads.ContainerView = function() {
  this.lastSelectedIndex = -1;
  org.apache.flex.html.beads.ContainerView.base(this, 'constructor');

  this.className = 'ContainerView';
};
goog.inherits(
    org.apache.flex.html.beads.ContainerView,
    org.apache.flex.core.BeadViewBase);


/**
 * Metadata
 *
 * @type {Object.<string, Array.<Object>>}
 */
org.apache.flex.html.beads.ContainerView.prototype.FLEXJS_CLASS_INFO =
    { names: [{ name: 'ContainerView',
                qName: 'org.apache.flex.html.beads.ContainerView' }],
    interfaces: [org.apache.flex.core.ILayoutParent]
    };


/**
 * @private
 * @type {Object}
 * This is also defined as protected on BeadViewBase, but GCC
 * doesn't seem to allow the Object.defineProperties to use it
 * without re-declaring it here.
 */
org.apache.flex.html.beads.ContainerView.prototype.strand_ = null;


/**
 * @private
 * @type {Object}
 */
org.apache.flex.html.beads.ContainerView.prototype.viewport_ = null;


/**
 * @private
 * @type {Object}
 */
org.apache.flex.html.beads.ContainerView.prototype.viewportModel_ = null;


/**
 * @private
 * @type {Object}
 */
org.apache.flex.html.beads.ContainerView.prototype.contentArea_ = null;


/**
 *
 */
org.apache.flex.html.beads.ContainerView.
    prototype.addOtherListeners = function() {
  this.strand_.addEventListener('childrenAdded',
      goog.bind(this.changeHandler, this));
  this.strand_.addEventListener('elementAdded',
      goog.bind(this.changeHandler, this));
  this.strand_.addEventListener('layoutNeeded',
     goog.bind(this.changeHandler, this));
  this.strand_.addEventListener('itemsCreated',
     goog.bind(this.changeHandler, this));
};


/**
 * @return {Object} The container's child content area.
 */
org.apache.flex.html.beads.ContainerView.
    prototype.createContentView = function() {
  return this.strand_;
};


/**
 * @param {org.apache.flex.events.Event} event The event.
 */
org.apache.flex.html.beads.ContainerView.
    prototype.changeHandler = function(event) {
  this.createViewport();

  this.performLayout();
};


/**
 * @param {org.apache.flex.events.Event} event The event.
 */
org.apache.flex.html.beads.ContainerView.
    prototype.sizeChangeHandler = function(event) {
  this.addOtherListeners();
  this.changeHandler(event);
};


/**
 * @param {org.apache.flex.events.Event} event The event.
 */
org.apache.flex.html.beads.ContainerView.
    prototype.performLayout = function(event) {
  if (this.layout_ == null) {
    this.layout_ = this.strand_.getBeadByType(org.apache.flex.core.IBeadLayout);
    if (this.layout_ == null) {
      var m3 = org.apache.flex.core.ValuesManager.valuesImpl.getValue(this.strand_, 'iBeadLayout');
      this.layout_ = new m3();
      this.strand_.addBead(this.layout_);
    }
  }
  this.layout_.layout();

  this.adjustSizeAfterLayout();
};


/**
 *
 */
org.apache.flex.html.beads.ContainerView.
    prototype.adjustSizeAfterLayout = function() {
  var max = this.layout_.maxWidth;
  if (isNaN(this.resizableView.explicitWidth) && !isNaN(max))
    this.resizableView.setWidth(max, true);
  max = this.layout_.maxHeight;
  if (isNaN(this.resizableView.explicitHeight) && !isNaN(max))
    this.resizableView.setHeight(max, true);
};


/**
 *
 */
org.apache.flex.html.beads.ContainerView.
    prototype.determineContentSizeFromChildren = function() {
  // this function has no meaning in the HTML world
};


/**
 * Creates the viewport and viewportModel.
 */
org.apache.flex.html.beads.ContainerView.
    prototype.createViewport = function() {
  if (this.viewportModel_ == null) {
    this.viewportModel_ = new org.apache.flex.html.beads.models.ViewportModel();
    this.viewportModel_.contentArea = this.contentView;
    this.viewportModel_.contentIsHost = true;
    this.viewportModel_.contentWidth = this.strand_.width;
    this.viewportModel_.contentHeight = this.strand_.height;
    this.viewportModel_.contentX = 0;
    this.viewportModel_.contentY = 0;
  }
  if (this.viewport_ == null) {
    this.viewport_ = new org.apache.flex.html.supportClasses.Viewport();
    this.viewport_.model = this.viewportModel_;
    this.strand_.addBead(this.viewport_);
  }
  this.resizeViewport();
};


/**
 * Adjusts the size of the viewportModel's viewport parameters to match those
 * of the strand.
 */
org.apache.flex.html.beads.ContainerView.
    prototype.resizeViewport = function() {
  this.viewportModel_.viewportHeight = this.strand_.height;
  this.viewportModel_.viewportWidth = this.strand_.width;
  this.viewportModel_.viewportX = 0;
  this.viewportModel_.viewportY = 0;
};


Object.defineProperties(org.apache.flex.html.beads.ContainerView.prototype, {
    /** @export */
    contentView: {
        /** @this {org.apache.flex.html.beads.ContainerView} */
        get: function() {
            return this.contentArea_;
        }
    },
    /** @export */
    resizableView: {
        /** @this {org.apache.flex.html.beads.ContainerView} */
        get: function() {
            return this.strand_;
        },
        set: function(value) {
        }
    },
    /** @export */
    strand: {
        /** @this {org.apache.flex.html.beads.ContainerView} */
        set: function(value) {
            org.apache.flex.utils.Language.superSetter(org.apache.flex.html.beads.ContainerView, this, 'strand', value);
            this.contentArea_ = this.createContentView();
            if (this.strand_.isWidthSizedToContent() &&
                this.strand_.isHeightSizedToContent())
              this.addOtherListeners();
            else {
              this.strand_.addEventListener('heightChanged',
                  goog.bind(this.changeHandler, this));
              this.strand_.addEventListener('widthChanged',
                  goog.bind(this.changeHandler, this));
              this.strand_.addEventListener('sizeChanged',
                  goog.bind(this.sizeChangeHandler, this));
              if (!isNaN(this.strand_.explicitWidth) &&
                  !isNaN(this.strand_.explicitHeight))
                this.addOtherListeners();
            }
         },
        /** @this {org.apache.flex.html.beads.ContainerView} */
         get: function() {
             return this.strand_;
        }
    },
    /** @export */
    viewport: {
        /** @this {org.apache.flex.html.beads.ContainerView} */
        set: function(value) {
            this.viewport_ = value;
        },
        /** @this {org.apache.flex.html.beads.ContainerView} */
        get: function() {
            return this.viewport_;
        }
    },
    /** @export */
    viewportModel: {
        /** @this {org.apache.flex.html.beads.ContainerView} */
        set: function(value) {
            this.viewportModel_ = value;
        },
        /** @this {org.apache.flex.html.beads.ContainerView} */
        get: function() {
            return this.viewportModel_;
        }
    }

});
