#!/usr/local/bin/python3.6

def printbc(bc):
    height = '\035h\120'  # height 120 - number of dots. One dot is 1/180 inch
    width = '\035w\002'  # width - this is a code of either 2,3,4,5 or 6. 2 is thinest 6 is widest
    humanreadable = '\035H\002'
    code39 = '\035k\105*123456*'  #  Code 39
    code128 =  '\035k\111\006123456'
    print(height)
    print(width)
    print(humanreadable)
    print(code39)

if __name__ == "__main__":
	print("hello World")
	printbc("here")	
	print("goodbye World")

