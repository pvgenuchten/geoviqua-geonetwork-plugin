## About ##

A plugin which enables the creation, editing and cataloguing of metadata that uses the [GeoViQua 3.1.0 schema][3], within a standard [GeoNetwork v2.8.0][4] installation. 

## Installation ##

[Download the latest zip archive][2] of the metadata schema plugin and upload it through the [GeoNetwork administration interface][1]. It is crucial that the plugin name given is **iso19139.geoviqua**.

To install the schema plugin manually, the zip archive must be extracted to GeoNetwork's schema directory (by default this is `INSTALL_DIR/web/geonetwork/WEB-INF/data/config/schema_plugins`) and into a folder named **iso19139.geoviqua**.

Alternatively, you could clone the repo directly via Git:

	cd INSTALL_DIR/web/geonetwork/WEB-INF/data/config/schema_plugins
	git clone https://github.com/lushc/geoviqua-geonetwork-plugin.git iso19139.geoviqua

[1]: http://geonetwork-opensource.org/manuals/2.8.0/eng/users/managing_metadata/schemas/index.html
[2]: https://github.com/lushc/geoviqua-geonetwork-plugin/archive/2.8.x-dev.zip
[3]: http://schemas.geoviqua.org/GVQ/3.1.0/
[4]: http://www.geonetwork-opensource.org/ 