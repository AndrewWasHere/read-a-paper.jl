import HTTP


"""
Paper information.
"""
struct Paper
    title::AbstractString
    url::AbstractString
end

"""
Repo information.
"""
struct Repo
    path::AbstractString
    url::AbstractString
end

"""
Load recent papers from `path`.
"""
function recent_papers(path::AbstractString)
    isfile(path) ? readlines(path) : Vector{AbstractString}()
end

"""
Write `depth` most recent papers to `path`.
"""
function update_recent_papers(
    path::AbstractString, 
    recent_papers::Vector{<:AbstractString}, 
    latest_paper::Paper, 
    depth::Integer
)
    all_papers = first([ [latest_paper.url] ; recent_papers ], depth)
    open(path, "w") do f
        for p in all_papers
            println(f, p)
        end
    end
end

"""
Create the base URL in repo for path.

path = /path/to/repo/subdir
repo.path = /path/to/repo
repo.url = https://github.com/love_a_paper/love_a_paper
returns https://github.com/love_a_paper/love_a_paper/subdir
"""
function link_url(path::AbstractString, repo::Repo)
    subdir = path[begin + length(repo.path):end]
    repo.url * "/blob/main" * subdir
end

"""
Extract PDF links listed in README.
"""
function papers_in_readme(root::AbstractString, file::AbstractString, repo::Repo)
    papers = Vector{Paper}()
    base_url = link_url(root, repo)
    for line in eachline(joinpath(root, file))
        m = match(r"\[(.*)\]\((.*)\)", line)
        if isnothing(m) || ! endswith(m[2], ".pdf")
            continue
        end
            
        title = m[1]
        url = startswith(m[2], "http") ? m[2] : "$base_url/$(m[2])"
        push!(papers, Paper(title, url))
    end

    return papers
end

"""
Find all papers in repo.
"""
function repo_papers(repo::Repo)
    papers = Vector{Paper}()
    for (root, dirs, files) in walkdir(repo.path)
        if root == repo.path
            # Skip root directory.
            continue
        end
        for f in files
            if f == "README.md"
                append!(papers, papers_in_readme(root, f, repo))
                break;
            end
        end
    end

    return papers
end

"""
Randomly select a paper that hasn't been chosen recently.
"""
function choose_paper(
    papers::Vector{Paper}, 
    recent_papers::Vector{<:AbstractString}
)
    while true
        p = rand(papers)
        if p.url ∉ recent_papers
            return p
        end
    end
end

"""
Suggest paper to endpoint.
"""
function suggest(paper::Paper)
    println("How about reading '$(paper.title)' @ $(paper.url) ?")
end

function suggest(paper::Paper, url::AbstractString)
    println("Suggesting '$(paper.title)' to Discord.")

    headers = [
        "Content-Type" => "application/json", 
        "Accept" => "application/json"
    ]
    body = """{
        "content": "How about reading '$(paper.title)' @ $(paper.url) ?"
    }"""
    
    # Server will silently fail if something goes wrong, so ignore the response.
    HTTP.post(url, headers, body)

    return
end

"""
Entry point.
"""
function main()
    depth = 100
    paper_history = abspath("./paper_history.txt")
    repo = Repo(
        abspath("./papers-we-love"), 
        "https://github.com/papers-we-love/papers-we-love"
    )
    discord_webhook = readline("discord_webhook.txt")
    
    previously_suggested_papers = recent_papers(paper_history)
    all_papers = repo_papers(repo)
    if length(all_papers) == 0
        # Something went wrong. Ask for help.
        suggest(Paper("read-a-paper needs some TLC.", ""), discord_webhook)
    else
        chosen_paper = choose_paper(all_papers, previously_suggested_papers)
        update_recent_papers(
            paper_history, 
            previously_suggested_papers, 
            chosen_paper,
            depth
        )
        suggest(chosen_paper, discord_webhook)
    end
end

# Suggest a Paper.
main()
