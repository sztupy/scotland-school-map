import GeoJSON from 'ol/format/GeoJSON.js';
import TopoJSON from 'ol/format/TopoJSON.js'
import Layer from 'ol/layer/Layer.js';
import Map from 'ol/Map.js';
import OSM from 'ol/source/OSM.js';
import TileLayer from 'ol/layer/WebGLTile.js';
import VectorSource from 'ol/source/Vector.js';
import View from 'ol/View.js';
import WebGLVectorLayerRenderer from 'ol/renderer/webgl/VectorLayer.js';
import VectorLayer from 'ol/layer/Vector.js';
import Papa from 'papaparse';
import chroma from 'chroma-js';
import {useGeographic} from 'ol/proj.js';
import {Fill, Stroke, Style} from 'ol/style.js';

useGeographic();

const colorScale = chroma.scale('Spectral');

const style = new Style({
  fill: new Fill({
    color: 'white'
  }),
  stroke: new Stroke({
    color: 'black',
    width: 0.5
  })
});

class WebGLLayer extends Layer {
  createRenderer() {
    return new WebGLVectorLayerRenderer(this, {
      fill: {
        attributes: {
          color: function (feature) {
            if (simdData[feature.get('DataZone')]) {
                return colorScale(simdData[feature.get('DataZone')] / 10).num();
            }
            return 16777215;
          },
          opacity: function () {
            return 0.5;
          },
        },
      },
      stroke: {
        attributes: {
          color: function (feature) {
            return 0;
          },
          width: function () {
            return 0.5;
          },
          opacity: function () {
            return 1;
          },
        },
      },
    });
  }
}

const osm = new TileLayer({
  source: new OSM(),
});

const vectorLayer = new WebGLLayer({
  source: new VectorSource({
    url: 'data/simd-simplified.topojson',
    format: new TopoJSON(),
  }),
});

const vector = new VectorLayer({
  source: new VectorSource({
    url: 'data/simd2020.geojson',
    format: new GeoJSON(),
  }),
  // background: 'white',
  // style: function (feature) {
  //   if (simdData[feature.get('DataZone')]) {
  //     style.getFill().setColor(colorScale(simdData[feature.get('DataZone')] / 10).hex());
  //   } else {
  //     style.getFill().setColor('white');
  //   }

  //   return style;
  // },
});

const map = new Map({
  layers: [osm, vectorLayer],
  target: 'map',
  view: new View({
    center: [-4.7, 57.0],
    zoom: 6.5,
  }),
});

const simdData = {};

Papa.parse(new URL("/scotland-school-map/data/simd2020_withinds.csv", document.baseURI).href, {
	worker: true,
    header: true,
    dynamicTyping: true,
    download: true,
    chunkSize: 1986840,
	step: function(row) {
		simdData[row.data['Data_Zone']] = row.data['SIMD2020v2_Decile'];
	},
    complete: function() {
        console.log('SIMD Data loaded');
    }
});
