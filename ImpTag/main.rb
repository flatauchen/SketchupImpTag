=begin
#===================================================================#
#	Plugin para importação de etiquetas com a possibilidade de		#
#	importar toda a estrutura de uma planilha ou apenas	editar		#
#	um arquivo TSV, texto separado por tabulação com cabeçalho.		#
#	Desenvolvido por: Flavio Tauchen								#
#===================================================================#
=end
# main.rb
require 'Sketchup.rb'

# Cria a toolbar
unless file_loaded?(__FILE__)

	# Verifica Idioma
	if Sketchup.get_locale.downcase == "pt-br"
		toolnomeedita		= "Edita etiquetas"
		tooltipedita		= "Abre o arquivo .tsv para editar a estrutura das etiquetas."
		toolnomecria		= "Cria etiquetas"
		tooltipcria			= "Cria as etiquetas no modelo atual com base no arquivo .tsv."
		toolnomeexp			= "Exporta etiquetas"
		tooltipexp			= "Exporta as etiquetas do modelo atual em um arquivo .tsv."
	else
		toolnomeedita		= "Edit tags"
		tooltipedita		= "Open the .tsv file to edit the tag structure."
		toolnomecria		= "Create tags"
		tooltipcria			= "Creates the tags in the current model based on the .tsv file."
		toolnomeexp			= "Export tags"
		tooltipexp			= "Exports the current model tags to a .tsv file."
	end

	# Define a toolbar
	barraet = UI::Toolbar.new("ImpTag")

	# Executa o módulo do botão de edição de etiquetas
	edet = UI::Command.new(toolnomeedita) do
		Sketchup.active_model.select_tool FlaTauchen::TiEdita_Etiquetas::Editar.new
	end

	# Define Características do botão de edição de etiquetas
	edet.small_icon = edet.large_icon = File.join(File.dirname(__FILE__).gsub('\\', '/'), "Img/edita.png")
	edet.tooltip = toolnomeedita
	edet.status_bar_text = tooltipedita
	barraet.add_item edet

	# Executa o módulo do botão de geração de etiquetas
	cret = UI::Command.new(toolnomecria) do
		Sketchup.active_model.select_tool FlaTauchen::TiCria_Etiquetas::Inserir.new
	end

	# Define Características do botão de geração de etiquetas
	cret.small_icon = cret.large_icon = File.join(File.dirname(__FILE__).gsub('\\', '/'), "Img/cria.png")
	cret.tooltip = toolnomecria
	cret.status_bar_text = tooltipcria
	barraet.add_item cret

	# Executa o módulo do botão de exportação de etiquetas
	exet = UI::Command.new(toolnomeexp) do
		Sketchup.active_model.select_tool FlaTauchen::TiExp_Etiquetas::Exportar.new
	end

	# Define Características do botão de exportação de etiquetas
	exet.small_icon = exet.large_icon = File.join(File.dirname(__FILE__).gsub('\\', '/'), "Img/exporta.png")
	exet.tooltip = toolnomeexp
	exet.status_bar_text = tooltipexp
	barraet.add_item exet

	# Mostra a toolbar e define a posição
	barraet.show unless barraet.get_last_state == 0
	file_loaded(__FILE__)
end

# Módulo do desenvolvedor
module FlaTauchen

	# Módulo de edição de etiquetas
	module TiEdita_Etiquetas

		# Classe para edição
		class Editar

			# Inicia a ação da classe
			def initialize
				edita_tsv
			end

			def edita_tsv

				puts "Editando as etiquetas"
				model = Sketchup.active_model
				layer_folders = model.layers.entries.grep(Sketchup::LayerFolder)
				pastas = []

				layer_folders.each do |folder|
					pastas << folder.name
				end

				if pastas.empty?
					puts "Nenhuma pasta encontrada no modelo."
				else
					puts "Pastas no modelo:"
					pastas.each do |nome|
					puts nome
				end
			end


			dir_EditEt = File.dirname(Sketchup.active_model.path.gsub('\\', '/'))
			Dir.chdir(dir_EditEt)
				if RUBY_PLATFORM =~ /darwin/
					# Este é um sistema macOS, então abrirá o TextEdit (editor de texto padrão)
					system("open -a TextEdit tags.tsv")
				elsif RUBY_PLATFORM =~ /mingw|mswin/
					# Este é um sistema Windows, então abrirá o Bloco de Notas
					system("notepad tags.tsv")
				else
					puts "Sistema não reconhecido."
				end
			end

		end
	end

	# Módulo de Geração de etiquetas
	module TiCria_Etiquetas

		# Classe para inserção
		class Inserir

			def initialize
				puts "Criando Etiquetas de "
				@manager = Sketchup.active_model.layers
				tabela=[]
				@dados=[]

				arquivo_tsv = File.join(File.dirname(Sketchup.active_model.path).gsub('\\', '/'), "tags.tsv")
				puts arquivo_tsv.to_s

				# Ler o arquivo TSV
				@dados = ler_arquivo_tsv(arquivo_tsv)
				criar_pastas_e_etiquetas
			end

			def ler_arquivo_tsv(arquivo)
				tabela = []

				File.open(arquivo, 'r') do |file|
					file.each_line do |line|
						linha = line.chomp.split("\t")
						tabela << linha
					end
				end

				tabela
			end

			def listar_pastas
				lista_pastas = []
				manager = Sketchup.active_model.layers
				# Itera sobre todas as pastas no gerenciador de camadas

				manager.each_folder do |folder|
					# Verifica se o nome da pasta não é nulo
					if folder.name
						lista_pastas << folder.name
					end
				end
				lista_pastas
			end

			def criar_ou_encontrar_pasta(pasta_nome)
				pasta = nil
				manager = Sketchup.active_model.layers
				lista_pastas = listar_pastas

				if lista_pastas.include?(pasta_nome)
					manager.each { |f| pasta = f if f.name == pasta_nome }
				else
					pasta = manager.add_folder(pasta_nome)
					#puts "A pasta "+pasta+" foi criada."
				end
				pasta
			end

			def criar_ou_encontrar_etiqueta(pasta, etiqueta_nome)
				etiqueta = nil
				pasta.each { |l| etiqueta = l if l.name == etiqueta_nome }

				if etiqueta.nil? && !etiqueta_nome.empty?
					etiqueta = @manager.add_layer(etiqueta_nome)
					pasta.add_layer(etiqueta)
				end
				etiqueta
			end

			def criar_pastas_e_etiquetas
				pastas = @dados[0] # A primeira linha da matriz contém os nomes das pastas (cabeçalho)
				pastas.each do |pasta_nome|
				pasta = criar_ou_encontrar_pasta(pasta_nome)

				@dados[1..-1].each do |linha|
					etiqueta_nome = linha[pastas.index(pasta_nome)]
					criar_ou_encontrar_etiqueta(pasta, etiqueta_nome)
				end
			  end
			end
		end
	end

	module TiExp_Etiquetas

		class Exportar

			def initialize
				exportar_para_tsv
			end

			def exportar_para_tsv

				model = Sketchup.active_model
				layers = model.layers
				etiquetas = []

				etiquetas_nivel_0 = []
				layers.each_layer do |layer|
				  etiquetas_nivel_0 << layer.name
				end
				etiquetas << { 'Raiz' => etiquetas_nivel_0 }

				layers.each_folder do |folder|
				  etiquetas_nivel_1 = []
				  #etiquetas_nivel_1 << folder.name

				  folder.each_layer do |layer|
					etiquetas_nivel_1 << "#{layer.name}"  # Ajustando a tabulação para ficar na mesma linha do nome da pasta
				  end

				  folder.each_folder do |sub_folder|
					etiquetas_nivel_1 << "\n\t#{sub_folder.name}"  # Adicionando uma nova linha antes das subpastas de nível 2
					sub_folder.each_layer do |layer|
					  etiquetas_nivel_1 << "#{layer.name}"  # Removendo a tabulação extra das etiquetas de nível 2
					end
				  end

				  etiquetas << { folder.name => etiquetas_nivel_1 }
				end

				caminho = UI.savepanel("Salvar Etiquetas", File.dirname(Sketchup.active_model.path).gsub('\\', '/'), "tsv.tsv")

				if caminho
				  File.open(caminho, 'w') do |file|
					etiquetas.each do |etiqueta|
					  etiqueta.each do |folder, labels|
						file.print folder
						labels.each { |label| file.print "\t#{label}" }
						file.puts
					  end
					end
				  end
				  puts "Etiquetas exportadas para: #{caminho}"
				else
				  puts 'Operação de exportação cancelada.'
				end

			end

		end

	end

end
