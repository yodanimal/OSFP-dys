<#
.SYNOPSIS
OSPF Routing using Dijkstra's algorithm in PowerShell.

.DESCRIPTION
The script defines a graph using an adjacency list where each node represents a network node (e.g., router).
Each edge has an associated weight (cost).
Dijkstra's algorithm is implemented to find the shortest path from a specified start node to all other nodes in the graph.

.PARAMETER startNode
The node to start the shortest path calculation.

.EXAMPLE
# Define the start node
    $startNode = "A"
    $result = Get-ShortestPath -startNode $startNode
    Write-Host "Shortest paths from node $startNode"
    foreach ($node in $result.Distances.Keys) {
        $distance = $result.Distances[$node]
        $path = $node
        $currentNode = $node
        while ($result.PreviousNodes[$currentNode] -ne $null) {
            $path = "$($result.PreviousNodes[$currentNode]) -> $path"
            $currentNode = $result.PreviousNodes[$currentNode]
        }
        Write-Host "$path (Distance: $distance)"
    }

.NOTES
#>

$graph = @{
    "A" = @{ "B" = 1; "C" = 4 }
    "B" = @{ "A" = 1; "C" = 2; "D" = 5 }
    "C" = @{ "A" = 4; "B" = 2; "D" = 1 }
    "D" = @{ "B" = 5; "C" = 1 }
}

# Dijkstra's Algorithm
function Get-ShortestPath {
    param (
        [string]$startNode
    )

    $distances = @{}
    $previousNodes = @{}
    $nodes = @()

    foreach ($node in $graph.Keys) {
        if ($node -eq $startNode) {
            $distances[$node] = 0
        } else {
            $distances[$node] = [int]::MaxValue
        }
        $previousNodes[$node] = $null
        $nodes += $node
    }

    while ($nodes.Count -gt 0) {
        $smallestNode = $null
        foreach ($node in $nodes) {
            if ($null -eq $smallestNode -or $distances[$node] -lt $distances[$smallestNode]) {
                $smallestNode = $node
            }
        }

        $nodes.Remove($smallestNode)

        if ($distances[$smallestNode] -eq [int]::MaxValue) {
            break
        }

        foreach ($neighbor in $graph[$smallestNode].Keys) {
            $alt = $distances[$smallestNode] + $graph[$smallestNode][$neighbor]
            if ($alt -lt $distances[$neighbor]) {
                $distances[$neighbor] = $alt
                $previousNodes[$neighbor] = $smallestNode
            }
        }
    }

    return @{
        Distances = $distances
        PreviousNodes = $previousNodes
    }
}

$startNode = "A"

$result = Get-ShortestPath -startNode $startNode

Write-Host "Shortest paths from node $startNode"
foreach ($node in $result.Distances.Keys) {
    $distance = $result.Distances[$node]
    $path = $node
    $currentNode = $node
    while ($null -ne $result.PreviousNodes[$currentNode]) {
        $path = "$($result.PreviousNodes[$currentNode]) -> $path"
        $currentNode = $result.PreviousNodes[$currentNode]
    }
    Write-Host "$path (Distance: $distance)"
}
