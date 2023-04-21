if fs.exists("/CCasm.lua") then shell.run("rm", "/CCasm.lua") end
if fs.exists("/CCasm/") then shell.run("rm", "/CCasm/") end

fs.makeDir("/CCasm")
fs.makeDir("/CCasm/Lexer")
fs.makeDir("/CCasm/Parser")
fs.makeDir("/CCasm/util")

shell.run("wget", "https://raw.githubusercontent.com/NihilisticPuffin/CCasm/main/CCasm.lua", "/CCasm.lua")

shell.run("wget", "https://raw.githubusercontent.com/NihilisticPuffin/CCasm/main/CCasm/Lexer/lex.lua", "/CCasm/Lexer/lex.lua")
shell.run("wget", "https://raw.githubusercontent.com/NihilisticPuffin/CCasm/main/CCasm/Lexer/Token.lua", "/CCasm/Lexer/Token.lua")

shell.run("wget", "https://raw.githubusercontent.com/NihilisticPuffin/CCasm/main/CCasm/Parser/parse.lua", "/CCasm/Parser/parse.lua")

shell.run("wget", "https://raw.githubusercontent.com/NihilisticPuffin/CCasm/main/CCasm/util/switch.lua", "/CCasm/util/switch.lua")
shell.run("wget", "https://raw.githubusercontent.com/NihilisticPuffin/CCasm/main/CCasm/util/consts.lua", "/CCasm/util/consts.lua")