sub init()
    m.top.functionName = "loadGameContent"
    
end sub

sub loadGameContent() 
    oneRow = fetchScoreboard()
    if oneRow.count() = 0
        noDataFound(oneRow)
    end if
    m.top.content = formatContent(oneRow)
end sub

function formatContent(list As Object) as Object 'Formats content into content nodes so they can be passed into the RowList
    root = CreateObject("roSGNode","ContentNode")
    row = CreateObject("roSGNode","ContentNode")    
    for each aa in list
        child = CreateObject("roSGNode","ContentNode")
        child.setFields(aa)
        row.appendChild(child)
    end for
    root.appendChild(row)
    return root
end function

function fetchScoreboard() as Object
    ' TODO Validate url
    jsonFeed = m.top.jsonFeed
    url = CreateObject("roUrlTransfer") 'component used to transfer data to/from remote servers
    url.SetUrl(jsonFeed)
    ' TODO Implement error handling
    response = url.GetToString()
    json = parseJsonResponse(response)
    result = []
    if json <> invalid then
        gamesArray = getGameArray(json)
    else
        return result
    end if
    for each game in gamesArray
        game = filterGameData(game)
        result.Push(game)
    end for
    return result
end function

function filterGameData(game as Object) as Object
    filter = {}
    filter.title = getTitle(game)
    filter.description = getDescription(game)
    posterUrl = getPosterUrl(game)
    filter.HDPosterUrl = posterUrl
    filter.SDPosterUrl = posterUrl
    filter.ShortDescriptionLine1 = getGameStatus(game)
    filter.releaseDate = getLocalTime(game)
    return filter
end function

function parseJsonResponse(jsonString As String) as dynamic 'takes in content feed as string
    if jsonString = invalid return invalid
    json = ParseJson(jsonString)
    if json = invalid return invalid
    return json
end function

sub noDataFound(list as Object)
    data = {}
    data.title = "No game data found"
    list.push(data)
end sub

function getGameArray(json as Object) as Object
    'json.data.games.game
    if json.DoesExist("data")
        data = json.data
        if data.DoesExist("games")
            games = data.games
            if games.DoesExist("game")
                gameArray = games.game
                if type(gameArray) = "roArray"
                    return gameArray
                else if type(gameArray) = "roAssociativeArray" 'If feed contains one game then we don't get an array
                    array = []
                    array.push(gameArray)
                    return array
                end if
            end if
        end if
    end if
    return []
end function 

function getTitle(game as Object) as Object
    if game.DoesExist("away_team_name") and game.DoesExist("home_team_name")
        return game.away_team_name + " @ " + game.home_team_name
    end if
    return ""
end function

function getDescription(game as Object) as Object
    if game.DoesExist("away_name_abbrev")
        awayName = game.away_name_abbrev
    end if
    if game.DoesExist("home_name_abbrev")
        homeName = game.home_name_abbrev
    end if
    if game.DoesExist("linescore")
        linescore = game.linescore
        if linescore.DoesExist("r")
            runs = linescore.r
            if runs.doesExist("away") and runs.DoesExist("home")
                return awayName + " " + runs.away + " " + homeName + " " + runs.home
            end if
        end if
    end if
    return ""
end function

function getPosterUrl(game as Object) as Object
    posterUrl = "pkg:/images/mlb-logo.gif"
    if game.DoesExist("video_thumbnails")
        videoThumbnails = game.video_thumbnails
        if videoThumbnails.DoesExist("thumbnail")
            thumbnailArray = videoThumbnails.thumbnail
            if type(thumbnailArray) = "roArray"
                for each thumbnail in thumbnailArray
                    if thumbnail.DoesExist("scenario")
                        if thumbnail.scenario = "7"
                            if thumbnail.DoesExist("content")
                                posterUrl = thumbnail.content
                            end if
                        end if
                    end if
                end for
            end if
        end if
    end if
    return posterUrl
end function

function getGameStatus(game as Object) as Object
    result = ""
    if game.DoesExist("status")
        stat = game.status
        if stat.DoesExist("status")
            result = stat.status
        end if
        if stat.DoesExist("inning")
            result = result + "/" + stat.inning
        end if
    end if
    return result
end function

function getLocalTime(game as Object) as Object
    if game.DoesExist("home_time") and game.DoesExist("home_time_zone")
        return game.home_time + " " + game.home_time_zone
    end if
    return ""
end function
