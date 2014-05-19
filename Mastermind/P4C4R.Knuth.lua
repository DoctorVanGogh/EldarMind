-----------------------------------------------------------------------------------------------
-- Lua Script for 4 pieces, 4 colors, repetitions allowed 'Mastermind' solution with a maximum
-- of 4 guesses
-- Copyright (c) DoctorVanGogh on Wildstar forums
-----------------------------------------------------------------------------------------------

local MAJOR,MINOR = "DoctorVanGogh:Lib:Mastermind:P4C4R:Knuth-1.0", 1

-- Get a reference to the package information if any
local APkg = Apollo.GetPackage(MAJOR)
-- If there was an older version loaded we need to see if this is newer
if APkg and (APkg.nVersion or 0) >= MINOR then
	return -- no upgrade needed
end

local sPackageTuple = "DoctorVanGogh:Lib:Tuple-1.0"

local tuple = Apollo.GetPackage(sPackageTuple).tPackage

-----------------------------------------------------------------------------------------------
--	Solution table
--	Lua-fied output of Knuth's[1] algorithm[2] to generate a modified lookup table (Knuth's 
--	original version used 6 colors).
--
--	Performance:
--
--	No. of Guesses	|	1	|	2	|	 3	|	 4	|	5	|
--	Patterns		|	1	|	9	|	84  |  162	|	0	|
--	Average No. of Guesses: 3.6
--
--	[1]: http://www.dcc.fc.up.pt/~sssousa/RM09101.pdf
--	[2]: http://en.wikipedia.org/wiki/Mastermind_%28board_game%29#Five-guess_algorithm
-----------------------------------------------------------------------------------------------
local knuth = {
	guess = tuple(2,3,4,4),
	[tuple(2,1)] = {
		guess = tuple(4,3,3,4),
		[tuple(2,2)] = {
			guess = tuple(4,3,4,3),
		},
		[tuple(1,1)] = {
			guess = tuple(1,2,4,4),
			[tuple(1,3)] = {
				guess = tuple(2,4,1,4),
			},
			[tuple(2,1)] = {
				guess = tuple(1,3,4,2),
			},
			[tuple(1,2)] = {
				guess = tuple(2,4,2,4),
			},
		},
		[tuple(2,0)] = {
			guess = tuple(2,2,3,4),
			[tuple(2,0)] = {
				guess = tuple(4,2,4,4),
			},
			[tuple(3,0)] = {
				guess = tuple(2,1,3,4),
			},
			[tuple(1,2)] = {
				guess = tuple(1,3,2,4),
			},
		},
		[tuple(0,2)] = {
			guess = tuple(2,2,4,3),
			[tuple(2,0)] = {
				guess = tuple(2,4,4,1),
			},
			[tuple(3,0)] = {
				guess = tuple(2,1,4,3),
			},
			[tuple(2,1)] = {
				guess = tuple(2,4,4,2),
			},
		},
		[tuple(3,0)] = {
			guess = tuple(4,3,1,4),
		},
		[tuple(2,1)] = {
			guess = tuple(3,3,2,4),
			[tuple(1,1)] = {
				guess = tuple(4,3,4,1),
			},
		},
		[tuple(1,2)] = {
			guess = tuple(3,4,4,4),
			[tuple(2,0)] = {
				guess = tuple(3,3,4,2),
			},
			[tuple(3,0)] = {
				guess = tuple(3,1,4,4),
			},
		},
	},
	[tuple(0,0)] = {
		guess = tuple(1,1,1,1),
	},
	[tuple(0,1)] = {
		guess = tuple(1,3,1,1),
		[tuple(2,1)] = {
			guess = tuple(1,1,1,2),
			[tuple(2,2)] = {
				guess = tuple(1,1,2,1),
			},
			[tuple(2,1)] = {
				guess = tuple(4,1,1,1),
			},
		},
		[tuple(0,2)] = {
			guess = tuple(3,1,3,3),
		},
		[tuple(3,0)] = {
			guess = tuple(1,4,1,1),
			[tuple(3,0)] = {
				guess = tuple(1,2,1,1),
			},
		},
		[tuple(1,1)] = {
			guess = tuple(1,1,2,2),
		},
		[tuple(1,0)] = {
			guess = tuple(1,2,2,2),
		},
		[tuple(1,2)] = {
			guess = tuple(1,4,3,4),
			[tuple(1,1)] = {
				guess = tuple(3,1,3,1),
			},
			[tuple(2,0)] = {
				guess = tuple(1,1,3,3),
			},
			[tuple(0,2)] = {
				guess = tuple(3,1,1,3),
			},
		},
		[tuple(2,2)] = {
			guess = tuple(1,4,3,4),
			[tuple(1,1)] = {
				guess = tuple(1,1,1,3),
			},
			[tuple(2,0)] = {
				guess = tuple(1,1,3,1),
			},
			[tuple(0,2)] = {
				guess = tuple(3,1,1,1),
			},
		},
		[tuple(2,0)] = {
			guess = tuple(1,2,1,2),
			[tuple(2,2)] = {
				guess = tuple(1,2,2,1),
			},
		},
	},
	[tuple(0,2)] = {
		guess = tuple(3,4,1,1),
		[tuple(2,1)] = {
			guess = tuple(1,4,1,2),
			[tuple(2,2)] = {
				guess = tuple(1,4,2,1),
			},
			[tuple(1,3)] = {
				guess = tuple(4,2,1,1),
			},
			[tuple(2,1)] = {
				guess = tuple(3,1,1,2),
			},
			[tuple(0,3)] = {
				guess = tuple(3,1,2,1),
			},
		},
		[tuple(0,1)] = {
			guess = tuple(4,2,2,2),
		},
		[tuple(0,2)] = {
			guess = tuple(1,2,2,3),
			[tuple(2,2)] = {
				guess = tuple(1,2,3,2),
			},
			[tuple(3,0)] = {
				guess = tuple(1,2,3,3),
			},
			[tuple(1,2)] = {
				guess = tuple(4,1,2,2),
			},
		},
		[tuple(0,3)] = {
			guess = tuple(1,1,2,3),
			[tuple(2,2)] = {
				guess = tuple(1,1,3,2),
			},
			[tuple(2,0)] = {
				guess = tuple(4,1,3,3),
			},
		},
		[tuple(3,0)] = {
			guess = tuple(3,4,3,4),
			[tuple(1,1)] = {
				guess = tuple(4,4,1,1),
			},
			[tuple(1,0)] = {
				guess = tuple(3,2,1,1),
			},
			[tuple(3,0)] = {
				guess = tuple(3,4,3,1),
			},
			[tuple(2,1)] = {
				guess = tuple(3,4,1,3),
			},
		},
		[tuple(1,1)] = {
			guess = tuple(4,2,1,2),
			[tuple(2,2)] = {
				guess = tuple(4,2,2,1),
			},
			[tuple(1,1)] = {
				guess = tuple(3,1,3,2),
			},
			[tuple(1,3)] = {
				guess = tuple(1,4,2,2),
			},
			[tuple(0,2)] = {
				guess = tuple(3,1,2,3),
			},
			[tuple(1,2)] = {
				guess = tuple(3,1,2,2),
			},
		},
		[tuple(1,0)] = {
			guess = tuple(3,3,3,4),
			[tuple(1,1)] = {
				guess = tuple(3,2,2,3),
			},
			[tuple(1,0)] = {
				guess = tuple(3,2,2,2),
			},
			[tuple(2,0)] = {
				guess = tuple(3,2,3,2),
			},
			[tuple(2,1)] = {
				guess = tuple(3,2,3,3),
			},
		},
		[tuple(1,3)] = {
			guess = tuple(4,1,1,3),
			[tuple(2,2)] = {
				guess = tuple(4,1,3,1),
			},
		},
		[tuple(1,2)] = {
			guess = tuple(1,2,1,3),
			[tuple(2,2)] = {
				guess = tuple(1,2,3,1),
			},
			[tuple(2,0)] = {
				guess = tuple(1,4,3,3),
			},
			[tuple(1,2)] = {
				guess = tuple(4,1,1,2),
			},
			[tuple(0,3)] = {
				guess = tuple(4,1,2,1),
			},
		},
		[tuple(2,2)] = {
			guess = tuple(1,4,1,3),
			[tuple(2,2)] = {
				guess = tuple(1,4,3,1),
			},
		},
		[tuple(2,0)] = {
			guess = tuple(3,2,1,3),
			[tuple(2,2)] = {
				guess = tuple(3,2,3,1),
			},
			[tuple(2,0)] = {
				guess = tuple(3,4,3,3),
			},
			[tuple(3,0)] = {
				guess = tuple(3,2,1,2),
			},
			[tuple(2,1)] = {
				guess = tuple(3,2,2,1),
			},
		},
	},
	[tuple(0,3)] = {
		guess = tuple(4,2,1,3),
		[tuple(2,2)] = {
			guess = tuple(4,1,2,3),
			[tuple(1,3)] = {
				guess = tuple(4,2,3,1),
			},
		},
		[tuple(1,1)] = {
			guess = tuple(4,4,2,2),
		},
		[tuple(2,0)] = {
			guess = tuple(4,4,3,3),
		},
		[tuple(1,3)] = {
			guess = tuple(1,4,2,3),
			[tuple(1,3)] = {
				guess = tuple(3,4,1,2),
			},
			[tuple(0,4)] = {
				guess = tuple(4,1,3,2),
			},
		},
		[tuple(3,0)] = {
			guess = tuple(4,2,3,3),
			[tuple(2,0)] = {
				guess = tuple(4,4,1,3),
			},
			[tuple(3,0)] = {
				guess = tuple(4,2,2,3),
			},
		},
		[tuple(2,1)] = {
			guess = tuple(4,2,3,2),
			[tuple(2,0)] = {
				guess = tuple(4,4,1,2),
			},
		},
		[tuple(1,2)] = {
			guess = tuple(3,4,2,3),
			[tuple(1,1)] = {
				guess = tuple(4,4,3,1),
			},
			[tuple(2,0)] = {
				guess = tuple(4,4,2,1),
			},
		},
		[tuple(0,3)] = {
			guess = tuple(3,4,3,2),
			[tuple(3,0)] = {
				guess = tuple(3,4,2,2),
			},
		},
		[tuple(0,4)] = {
			guess = tuple(1,4,3,2),
			[tuple(1,3)] = {
				guess = tuple(3,4,2,1),
			},
		},
	},
	[tuple(0,4)] = {
		guess = tuple(4,4,2,3),
		[tuple(2,2)] = {
			guess = tuple(4,4,3,2),
		},
	},
	[tuple(1,1)] = {
		guess = tuple(1,4,1,4),
		[tuple(2,1)] = {
			guess = tuple(1,1,3,4),
			[tuple(2,2)] = {
				guess = tuple(3,1,1,4),
			},
			[tuple(3,0)] = {
				guess = tuple(1,1,2,4),
			},
			[tuple(0,3)] = {
				guess = tuple(2,4,1,1),
			},
		},
		[tuple(0,0)] = {
			guess = tuple(3,3,2,3),
			[tuple(2,2)] = {
				guess = tuple(3,3,3,2),
			},
			[tuple(2,0)] = {
				guess = tuple(2,2,2,3),
			},
			[tuple(0,2)] = {
				guess = tuple(2,2,3,2),
			},
			[tuple(3,0)] = {
				guess = tuple(3,3,2,2),
			},
			[tuple(1,2)] = {
				guess = tuple(2,2,3,3),
			},
		},
		[tuple(0,1)] = {
			guess = tuple(2,1,2,3),
			[tuple(2,2)] = {
				guess = tuple(2,1,3,2),
			},
			[tuple(1,0)] = {
				guess = tuple(4,3,3,3),
			},
			[tuple(1,3)] = {
				guess = tuple(2,2,3,1),
			},
			[tuple(3,0)] = {
				guess = tuple(2,1,3,3),
			},
			[tuple(1,2)] = {
				guess = tuple(3,3,2,1),
			},
		},
		[tuple(0,2)] = {
			guess = tuple(3,1,4,3),
			[tuple(1,1)] = {
				guess = tuple(2,1,3,1),
			},
			[tuple(0,4)] = {
				guess = tuple(4,3,3,1),
			},
		},
		[tuple(0,3)] = {
			guess = tuple(3,1,4,1),
		},
		[tuple(0,4)] = {
			guess = tuple(4,1,4,1),
		},
		[tuple(3,0)] = {
			guess = tuple(4,4,1,4),
			[tuple(2,0)] = {
				guess = tuple(1,2,1,4),
			},
		},
		[tuple(1,1)] = {
			guess = tuple(1,3,3,3),
			[tuple(1,1)] = {
				guess = tuple(2,1,1,3),
			},
			[tuple(1,0)] = {
				guess = tuple(1,2,4,2),
			},
			[tuple(0,1)] = {
				guess = tuple(2,4,2,1),
			},
			[tuple(2,0)] = {
				guess = tuple(1,3,2,1),
			},
			[tuple(2,1)] = {
				guess = tuple(4,3,1,3),
			},
			[tuple(1,2)] = {
				guess = tuple(3,1,3,4),
			},
		},
		[tuple(1,0)] = {
			guess = tuple(1,3,2,3),
			[tuple(2,2)] = {
				guess = tuple(1,3,3,2),
			},
			[tuple(1,0)] = {
				guess = tuple(2,4,2,2),
			},
			[tuple(1,3)] = {
				guess = tuple(3,3,1,2),
			},
			[tuple(3,0)] = {
				guess = tuple(1,3,2,2),
			},
			[tuple(1,2)] = {
				guess = tuple(2,2,1,3),
			},
		},
		[tuple(1,2)] = {
			guess = tuple(1,1,4,3),
			[tuple(1,1)] = {
				guess = tuple(4,4,4,1),
			},
			[tuple(3,0)] = {
				guess = tuple(1,1,4,2),
			},
			[tuple(2,1)] = {
				guess = tuple(1,2,4,1),
			},
			[tuple(0,4)] = {
				guess = tuple(4,3,1,1),
			},
		},
		[tuple(2,2)] = {
			guess = tuple(4,1,1,4),
			[tuple(0,4)] = {
				guess = tuple(1,4,4,1),
			},
		},
		[tuple(2,0)] = {
			guess = tuple(1,2,2,4),
			[tuple(1,1)] = {
				guess = tuple(1,3,1,2),
			},
			[tuple(0,4)] = {
				guess = tuple(2,4,1,2),
			},
		},
	},
	[tuple(3,0)] = {
		guess = tuple(1,3,3,4),
		[tuple(1,1)] = {
			guess = tuple(2,1,4,4),
			[tuple(2,0)] = {
				guess = tuple(2,3,4,2),
			},
		},
		[tuple(1,0)] = {
			guess = tuple(2,4,4,4),
			[tuple(3,0)] = {
				guess = tuple(2,2,4,4),
			},
		},
		[tuple(2,0)] = {
			guess = tuple(4,3,4,4),
			[tuple(2,0)] = {
				guess = tuple(2,3,2,4),
			},
		},
		[tuple(3,0)] = {
			guess = tuple(2,3,3,4),
			[tuple(2,0)] = {
				guess = tuple(1,3,4,4),
			},
		},
		[tuple(2,1)] = {
			guess = tuple(3,3,4,4),
			[tuple(2,0)] = {
				guess = tuple(2,3,1,4),
			},
		},
		[tuple(1,2)] = {
			guess = tuple(2,3,4,3),
			[tuple(3,0)] = {
				guess = tuple(2,3,4,1),
			},
		},
	},
	[tuple(1,0)] = {
		guess = tuple(1,2,1,4),
		[tuple(2,1)] = {
			guess = tuple(2,2,1,1),
		},
		[tuple(0,0)] = {
			guess = tuple(3,3,3,3),
		},
		[tuple(0,1)] = {
			guess = tuple(3,3,3,1),
		},
		[tuple(0,2)] = {
			guess = tuple(2,1,2,2),
		},
		[tuple(0,3)] = {
			guess = tuple(2,1,2,1),
		},
		[tuple(3,0)] = {
			guess = tuple(1,1,1,4),
		},
		[tuple(1,1)] = {
			guess = tuple(1,3,3,1),
			[tuple(2,2)] = {
				guess = tuple(3,3,1,1),
			},
			[tuple(1,0)] = {
				guess = tuple(2,2,2,1),
			},
		},
		[tuple(1,0)] = {
			guess = tuple(1,3,3,3),
			[tuple(2,2)] = {
				guess = tuple(3,3,1,3),
			},
			[tuple(0,0)] = {
				guess = tuple(2,2,2,2),
			},
		},
		[tuple(1,2)] = {
			guess = tuple(2,1,1,2),
			[tuple(1,1)] = {
				guess = tuple(1,1,4,1),
			},
			[tuple(3,0)] = {
				guess = tuple(2,1,1,1),
			},
		},
		[tuple(2,0)] = {
			guess = tuple(1,3,1,3),
			[tuple(1,0)] = {
				guess = tuple(2,2,1,2),
			},
			[tuple(3,0)] = {
				guess = tuple(1,3,1,1),
			},
		},
	},
	[tuple(1,3)] = {
		guess = tuple(4,2,3,4),
		[tuple(2,2)] = {
			guess = tuple(4,2,4,3),
		},
		[tuple(1,3)] = {
			guess = tuple(3,4,2,4),
		},
		[tuple(0,4)] = {
			guess = tuple(3,4,4,2),
		},
	},
	[tuple(1,2)] = {
		guess = tuple(3,2,3,4),
		[tuple(2,1)] = {
			guess = tuple(3,1,2,4),
			[tuple(1,3)] = {
				guess = tuple(3,2,4,1),
			},
			[tuple(1,2)] = {
				guess = tuple(3,2,4,2),
			},
		},
		[tuple(0,2)] = {
			guess = tuple(1,4,3,4),
			[tuple(2,2)] = {
				guess = tuple(1,4,4,3),
			},
			[tuple(1,1)] = {
				guess = tuple(4,4,4,2),
			},
			[tuple(2,1)] = {
				guess = tuple(1,4,4,2),
			},
			[tuple(1,2)] = {
				guess = tuple(4,4,4,3),
			},
			[tuple(0,3)] = {
				guess = tuple(4,1,4,2),
			},
			[tuple(0,4)] = {
				guess = tuple(4,1,4,3),
			},
		},
		[tuple(0,3)] = {
			guess = tuple(2,4,2,3),
			[tuple(1,3)] = {
				guess = tuple(4,3,2,2),
			},
			[tuple(3,0)] = {
				guess = tuple(2,4,1,3),
			},
			[tuple(1,2)] = {
				guess = tuple(4,3,2,1),
			},
			[tuple(0,3)] = {
				guess = tuple(4,3,1,2),
			},
		},
		[tuple(0,4)] = {
			guess = tuple(4,3,2,3),
		},
		[tuple(3,0)] = {
			guess = tuple(1,2,3,4),
			[tuple(2,2)] = {
				guess = tuple(3,2,1,4),
			},
			[tuple(2,0)] = {
				guess = tuple(3,4,3,4),
			},
			[tuple(2,1)] = {
				guess = tuple(3,2,2,4),
			},
		},
		[tuple(1,1)] = {
			guess = tuple(1,4,2,4),
			[tuple(2,2)] = {
				guess = tuple(4,1,2,4),
			},
			[tuple(3,0)] = {
				guess = tuple(4,4,2,4),
			},
			[tuple(1,2)] = {
				guess = tuple(3,4,4,1),
			},
			[tuple(0,3)] = {
				guess = tuple(4,2,4,2),
			},
			[tuple(0,4)] = {
				guess = tuple(4,2,4,1),
			},
		},
		[tuple(1,3)] = {
			guess = tuple(2,4,3,3),
			[tuple(1,3)] = {
				guess = tuple(4,3,3,2),
			},
		},
		[tuple(1,2)] = {
			guess = tuple(1,2,4,3),
			[tuple(2,0)] = {
				guess = tuple(3,4,4,3),
			},
			[tuple(1,3)] = {
				guess = tuple(3,1,4,2),
			},
			[tuple(0,3)] = {
				guess = tuple(2,4,3,2),
			},
			[tuple(0,4)] = {
				guess = tuple(2,4,3,1),
			},
		},
		[tuple(2,2)] = {
			guess = tuple(3,2,4,3),
		},
		[tuple(2,0)] = {
			guess = tuple(4,1,3,4),
			[tuple(2,2)] = {
				guess = tuple(1,4,3,4),
			},
			[tuple(2,0)] = {
				guess = tuple(4,2,2,4),
			},
			[tuple(1,3)] = {
				guess = tuple(3,4,1,4),
			},
			[tuple(3,0)] = {
				guess = tuple(4,4,3,4),
			},
			[tuple(2,1)] = {
				guess = tuple(4,2,1,4),
			},
		},
	},
	[tuple(2,2)] = {
		guess = tuple(2,4,3,4),
		[tuple(2,2)] = {
			guess = tuple(2,4,4,3),
		},
		[tuple(1,3)] = {
			guess = tuple(3,2,4,4),
			[tuple(1,3)] = {
				guess = tuple(4,3,2,4),
			},
		},
		[tuple(0,4)] = {
			guess = tuple(4,3,4,2),
		},
	},
	[tuple(2,0)] = {
		guess = tuple(1,4,1,4),
		[tuple(2,1)] = {
			guess = tuple(2,1,1,4),
		},
		[tuple(0,0)] = {
			guess = tuple(3,3,3,4),
			[tuple(1,1)] = {
				guess = tuple(2,3,2,3),
			},
			[tuple(1,0)] = {
				guess = tuple(2,3,2,2),
			},
			[tuple(2,0)] = {
				guess = tuple(2,3,3,2),
			},
			[tuple(2,1)] = {
				guess = tuple(2,3,3,3),
			},
		},
		[tuple(0,1)] = {
			guess = tuple(2,3,3,1),
			[tuple(1,1)] = {
				guess = tuple(3,3,4,3),
			},
			[tuple(1,0)] = {
				guess = tuple(2,2,4,2),
			},
			[tuple(3,0)] = {
				guess = tuple(2,3,2,1),
			},
		},
		[tuple(0,2)] = {
			guess = tuple(2,1,4,2),
			[tuple(2,2)] = {
				guess = tuple(2,2,4,1),
			},
			[tuple(1,1)] = {
				guess = tuple(3,3,4,1),
			},
		},
		[tuple(0,3)] = {
			guess = tuple(2,1,4,1),
		},
		[tuple(3,0)] = {
			guess = tuple(1,4,4,4),
			[tuple(2,0)] = {
				guess = tuple(1,3,1,4),
			},
		},
		[tuple(1,1)] = {
			guess = tuple(2,1,2,4),
			[tuple(1,1)] = {
				guess = tuple(2,3,1,1),
			},
			[tuple(0,2)] = {
				guess = tuple(1,3,4,3),
			},
		},
		[tuple(1,0)] = {
			guess = tuple(2,3,1,3),
			[tuple(1,1)] = {
				guess = tuple(3,3,3,4),
			},
			[tuple(1,0)] = {
				guess = tuple(2,2,2,4),
			},
			[tuple(3,0)] = {
				guess = tuple(2,3,1,2),
			},
		},
		[tuple(1,2)] = {
			guess = tuple(4,1,4,4),
			[tuple(1,1)] = {
				guess = tuple(1,3,4,1),
			},
		},
		[tuple(2,2)] = {
			guess = tuple(1,1,4,4),
		},
		[tuple(2,0)] = {
			guess = tuple(1,3,3,4),
			[tuple(2,2)] = {
				guess = tuple(3,3,1,4),
			},
			[tuple(1,1)] = {
				guess = tuple(2,2,1,4),
			},
			[tuple(1,0)] = {
				guess = tuple(4,4,4,4),
			},
		},
	},
}

local lookup = APkg and APkg.tPackage or knuth

Apollo.RegisterPackage(lookup, MAJOR, MINOR, {sPackageTuple})