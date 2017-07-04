local discordia = require('discordia')

require 'functions'
require 'filesystem'

local db = execute.getFile('db.txt','*a')
db = load("return " .. db)()

local client = discordia.Client()

local admin = {
	Bolodefchoco = true,
}
local keywords = {
	"teach"
}

local flashData = {}

client:on("ready",function()
	p("Running with " .. client.user.name .. " ...")
end)

client:on("messageCreate",function(message)
	if message.author == client.user then
		return
	end

	function message:text(where,id,text,...)
		-- message:text(1,"Global")
		-- message:text(2,"Whisper")
		if not flashData[message.author.name] then flashData[message.author.name] = {} end
		
		table.insert(flashData[message.author.name],id)
		return self[({"channel","author"})[where]]:sendMessage(string.format(text,...))
	end

	local channel = string.match(tostring(message.channel),"(.-)Channel:"):lower()
	-- channel = 1 -> chat
	-- channel = 2 -> whisper
	local _
	_,channel = table.find({"guildtext","private"},channel)
	
	local p = string.split(message.content,"[^%s]+",function(v)
		return string.lower(deactivateAccents(v))
	end)
	
	--[[
		Ids:
		
		?
		learnStart
		learnEnded
		learnGetSentence
		learnSetSentence
		learnConfirm
		learnTryNew
	
	]]
	
	if not flashData[message.author.name] then
		flashData[message.author.name] = {"?"}
	end
	local d = flashData[message.author.name]
	
	local sentence = db[table.concat(p," ")]
	
	if sentence and table.find({"learnEnded","?"},d[#d]) then
		message:text(channel,"?","*%s*",table.random(sentence))
		return
	else
		if channel == 1 then
			-- Global
			if p[1] == "teach" then
				message:text(2,"learnStart","Hey %s! Do you want to teach me something? :D\n> *Answer me with (yes / y) or (no / n)*",message.author.name)
				return
			end
		elseif channel == 2 then
			-- Whisper
			if d[#d] == "learnGetSentence" then
				p[1] = table.concat(p," ")
				if not table.find(keywords,p[1]) then
					message:text(2,"learnSetSentence","What should I answer when someone says \"%s\" to me?",p[1])
					d.__learnSentence = p[1]
				end
				return
			elseif d[#d] == "learnSetSentence" then
				p[1] = table.concat(p," ")
				message:text(2,"learnConfirm","So, when someone says \"%s\" I need to answer \"%s\"?\n> *Answer me with (yes / y) or (no / n)*",d.__learnSentence,p[1])
				d.__answerSentence = p[1]
				return
			elseif table.find({"yes","no","y","n"},p[1]) then
				local answer = table.find({"no","n"},p[1]) and "n" or table.find({"yes","y"},p[1]) and "y" or "?"

				if d[#d] == "learnStart" then
					if answer == "n" then
						message:text(2,"learnEnded","Ugh, okay! ^^'")
					elseif answer == "y" then
						message:text(2,"learnGetSentence","What sentence should I learn?")
					end
					return
				elseif d[#d] == "learnConfirm" then
					if answer == "n" then
						message:text(2,"learnSetSentence","Oh... So, what should I answer when someone says \"%s\" to me?",d.__learnSentence)
					elseif answer == "y" then
						if db[d.__learnSentence] then
							table.insert(db[d.__learnSentence],d.__answerSentence)
						else
							db[d.__learnSentence] = {d.__answerSentence}
						end
						d.__learnSentence = nil
						d.__answerSentence = nil
					
						execute.editFile("db.txt","w+",serializeTable(db))
						
						message:text(2,"learnTryNew","Annotated! (:\n...\nWould you like to teach me something else?\n> *Answer me with (yes / y) or (no / n)*")
					end
					return
				elseif d[#d] == "learnTryNew" then
					if answer == "n" then
						message:text(2,"learnEnded","Ugh, okay! ^^' Thank you so much!")
					elseif answer == "y" then
						message:text(2,"learnGetSentence","What sentence should I learn?")
					end
					return
				end
				return
			end
		end
	end
end)

client:run('MzMxNTA2NTYwNTExNjM5NTUz.DDwjtQ.YXFRs3uqzDCSMDhHpecXGfmcAIk')