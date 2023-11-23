=begin
#===================================================================#
#	Plugin para importação de etiquetas com a possibilidade de		#
#	importar toda a estrutura de uma planilha ou apenas	editar		#
#	um arquivo TSV, texto separado por tabulação com cabeçalho.		#
#	Desenvolvido por: Flavio Tauchen								#
#===================================================================#
=end
# ImpTag.rb
require 'sketchup.rb'
require 'extensions.rb'

module FlaTauchen
	module TiImpTag

		EXTVERSION		= "1.0.1"
		EXTTITLE		= "InpTag"
		EXTNAME			= "ImpTag"
		EXTDESCRIPTION	= "Importação de etiquetas."

		extdir = File.dirname(__FILE__).gsub(%r{//}) { "/" }
		extdir.force_encoding('UTF-8') if extdir.respond_to?(:force_encoding)
		EXTDIR = extdir

		loader = File.join( EXTDIR , EXTNAME , "main.rb" )

		EXTENSION				= SketchupExtension.new(EXTTITLE, loader)
		EXTENSION.creator		= "Flavio Tauchen"
		EXTENSION.description	= EXTDESCRIPTION
		EXTENSION.version		= EXTVERSION
		EXTENSION.copyright		= "Copyright 2010-#{Time.now.year} Tauchen Info"
		Sketchup.register_extension(EXTENSION, true)
	end
end
