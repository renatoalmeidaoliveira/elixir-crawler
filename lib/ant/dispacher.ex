defmodule Ant.Node do

	require Logger
  def run(uri) do
  	Logger.info "Inicio"
  	target  = Ant.Parser.process(uri)
  	domain = uri
  	query = ~r/\..{2,3}$/
  	dispatch( 25 , Ant.Analiser , :run , target , domain , query )
  end
  
  
  
  defp dispatch(num_processes, module, func, to_calculate , domain , query) do
    (1..num_processes)
    |> Enum.map(fn(_) -> spawn(module, func, [self]) end)
    |> schedule_processes(to_calculate, [] , [] , [] , domain , query)
  end

  defp schedule_processes(processes, queue, results, processed, queryResult , domain , query) do
    receive do 
      {:ready, pid} when length(queue) > 0 ->
        [ next | tail ] = queue
        send pid, {:link, next, self}
        schedule_processes(processes, tail, results, [next | processed] ,queryResult , domain ,query)

      {:ready, pid} ->
      	Logger.info "Processo morto"
        send pid, {:shutdown}
        if length(processes) > 1 do
          schedule_processes(List.delete(processes, pid), queue, results,  processed ,queryResult , domain , query)
        else
        	total = length processed
          {queryResult , total }
        end

      {:answer, uri, result, _pid} ->
       	notInQueue = Enum.filter(result , fn(x) -> 	!( Enum.member?(queue , x) || Enum.member?(processed, x)) end)
        queue = notInQueue ++ queue
        partialResult = Enum.filter(queue , fn(x) -> (String.match? x , query) end )
        queue = Enum.filter(queue , fn(x) -> (String.starts_with? x , ~s(#{domain})) && (!String.match? x , ~r/\..{2,3}$/) end )
        queryResult = queryResult ++ partialResult
        results = notInQueue ++ results
        schedule_processes(processes, queue, results ,  processed , queryResult , domain , query)
    end
  end
end