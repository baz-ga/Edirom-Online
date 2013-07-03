/**
 *  Edirom Online
 *  Copyright (C) 2011 The Edirom Project
 *  http://www.edirom.de
 *
 *  Edirom Online is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Edirom Online is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Edirom Online.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
Ext.define('de.edirom.online.controller.window.source.MeasureBasedView', {

    extend: 'Ext.app.Controller',

    views: [
        'window.source.MeasureBasedView'
    ],

    init: function() {
        this.control({
            'measureBasedView': {
                afterlayout: this.onMeasureBasedViewRendered,
                mdivSelected: this.onMdivSelected
            },
            
            'horizontalMeasureViewer': {
                showMeasure: this.onShowMeasure
            }
        });
    },

    onMeasureBasedViewRendered: function(view) {
        var me = this;

        if(view.initialized) return;
        view.initialized = true;

        Ext.Ajax.request({
            url: 'data/xql/getParts.xql',
            method: 'GET',
            params: {
                uri: view.owner.uri
            },
            success: function(response){
                var data = response.responseText;

                var parts = Ext.create('Ext.data.Store', {
                    fields: ['id', 'label', 'selectedByDefault', 'selected'],
                    data: Ext.JSON.decode(data)
                });

                me.partsLoaded(parts, view);
            }
        });
    },

    onMdivSelected: function(mdiv, view) {
        var me = this;

        Ext.Ajax.request({
            url: 'data/xql/getMeasures.xql',
            method: 'GET',
            params: {
                uri: view.owner.uri,
                mdiv: mdiv
            },
            success: function(response){
                var data = response.responseText;

                var measures = Ext.create('Ext.data.Store', {
                    fields: ['id', 'measures', 'name', 'mdivs'],
                    data: Ext.JSON.decode(data)
                });

                me.measuresLoaded(measures, view);
            }
        });        
    },

    measuresLoaded: function(measures, view) {
        view.setMeasures(measures);
    },
    
    partsLoaded: function(parts, view) {
        view.setParts(parts);
    },
    
    onShowMeasure: function(view, uri, measureId, count) {
        var me = this;

        Ext.Ajax.request({
            url: 'data/xql/getMeasurePage.xql',
            method: 'GET',
            params: {
                id: uri,
                measure: measureId,
                measureCount: count
            },
            success: Ext.bind(function(response){
                var data = response.responseText;
                this.showMeasure(view, uri, measureId, Ext.JSON.decode(data));
            }, me)
        });
    },
    
    showMeasure: function(view, uri, measureId, data) {
        view.showMeasure(data);
    }
});