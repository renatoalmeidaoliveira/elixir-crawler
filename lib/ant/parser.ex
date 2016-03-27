defmodule Ant.Parser do
	
	@user_agent [{"User-agent" , "myCrawler"}]
 
 	require Logger
 	
	def process(uri) do
		try do
			uri
			|> HTTPoison.get(@user_agent)
			|> handle_http_response
			|> tagSelector
			|> parser
		rescue
			_ ->
			[]
		end 
	end
	
	def handle_http_response(httpResponse) do
		case httpResponse do
  			{:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
    				body
  			_ ->
  					raise :error

		end
	end

	def tagSelector(string) do
		target = string
		target
		|> Exquery.tree
		|> Exquery.Query.all({:tag, "a", []})

	end

	
	def parser(array) do
		links = []
		[entrada | continua ] = array
		tag = elem(entrada , 0)
		attr = elem(tag , 2)
		map = Enum.into(attr , %{})
		links = links ++ [map["href"]]
		parser(continua , links)
	end

	def parser([] , links) do
		links = links -- ["/" , nil]
		links
	end

	def parser(array , links) do
		[entrada | continua ] = array
		tag = elem(entrada , 0)
		attr = elem(tag , 2)
		map = Enum.into(attr , %{})
		unless(Enum.any?(links, fn(x) -> x == map["href"] end ), do: links = links ++ [map["href"]])
		parser(continua , links)
	end


end
