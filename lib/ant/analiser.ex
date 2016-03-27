defmodule Ant.Analiser do


	require Logger
	
  def run(scheduler) do
     send scheduler, { :ready, self }
    receive do
      { :link, uri , client } ->
        send client, { :answer, uri , fetch(uri) ,  self }
        run(scheduler)
      { :shutdown } ->
        exit(:normal)
    end
  end

  def fetch(uri) do
   		list = Ant.Parser.process(uri)
    	list
  end
  
end