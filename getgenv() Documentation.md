# Cache

The **cache** library provides methods for modifying the internal Instance cache.

Note that some of the methods are only available as global functions. They will be tagged with `🌎 Global`.

---

## cache.invalidate

```lua
function invalidate(object: Instance): ()
```

Deletes `object` from the Instance cache. Effectively invalidates `object` as a reference to the underlying Instance.

### Parameters

 * `object` - The object to invalidate.

### Example

```lua
local Lighting = game:GetService("Lighting")
cache.invalidate(game:GetService("Lighting"))
print(Lighting, Lighting == game:GetService("Lighting")) --> Lighting, false
```

---

## cache.iscached

```lua
function iscached(object: Instance): boolean
```

Checks whether `object` exists in the Instance cache.

### Parameters

 * `object` - The object to find.

### Example

```lua
local Lighting = game:GetService("Lighting")
cache.invalidate(Lighting)
print(cache.iscached(Lighting)) --> false
```

---

## cache.replace

```lua
function replace(object: Instance, newObject: Instance): ()
```

Replaces `object` in the Instance cache with `newObject`.

### Parameters

 * `object` - The object to replace.
 * `newObject` - The new object to replace `object` with.

### Example

```lua
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

cache.replace(Lighting, Players)

print(Lighting) --> Players
```

---

## cloneref

`🌎 Global`

```lua
function cloneref(object: Instance): Instance
```

Returns a copy of the Instance reference to `object`. This is useful for managing an Instance without directly referencing it.

### Parameters

 * `object` - The Instance to clone.

### Example

```lua
local Lighting = game:GetService("Lighting")
local LightingClone = cloneref(Lighting)

print(Lighting == LightingClone) --> false
```

---

## compareinstances

`🌎 Global`

```lua
function compareinstances(a: Instance, b: Instance): boolean
```

Returns whether objects `a` and `b` both reference the same Instance.

### Parameters

 * `a` - The first Instance to compare.
 * `b` - The second Instance to compare.

### Example

```lua
local Lighting = game:GetService("Lighting")
local LightingClone = cloneref(Lighting)

print(Lighting == LightingClone) --> false
print(compareinstances(Lighting, LightingClone)) --> true
```


# Closures

The **closure** functions are used to create, identify, and interact with Luau closures.

---

## checkcaller

```lua
function checkcaller(): boolean
```

Returns whether the function currently running was called by the executor.

This is useful for metamethod hooks that behave differently when called by the game.

### Example

Prevent the executor from invoking `__namecall` with the global `game` object:

```lua
local refs = {}

refs.__namecall = hookmetamethod(game, "__namecall", function(...)
	local self = ...
	local isRunningOnExecutor = checkcaller()

	if isRunningOnExecutor then
		-- The executor invoked the __namecall method, so this will not affect the
		-- scripts in the game.
		if self == game then
			error("No __namecall on game allowed")
		end
	end

	return refs.__namecall(...)
end)

game:Destroy() --> Error "No __namecall on game allowed"
```

---

## clonefunction

```lua
clonefunction<T>(func: T): T
```

Generates a new closure based on the bytecode of function `func`.

### Parameters

 * `func` - The function to recreate.

### Example

```lua
local function foo()
	print("Hello, world!")
end

local bar = clonefunction(foo)

foo() --> Hello, world!
bar() --> Hello, world!
print(foo == bar) --> false
```

---

## getcallingscript

```lua
function getcallingscript(): BaseScript
```

Returns the script responsible for the currently running function.

### Example

Prevent scripts in PlayerGui from invoking the `__namecall` hook:

```lua
local refs = {}
local bannedScripts = game:GetService("Players").LocalPlayer.PlayerGui

refs.__namecall = hookmetamethod(game, "__namecall", function(...)
	local caller = getcallingscript()

	-- Use '.' notation to call the IsDescendantOf method without invoking
	-- __namecall and causing a recursive loop.
	local isBanned = caller.IsDescendantOf(caller, bannedScripts)

	if isBanned then
		error("Not allowed to invoke __namecall")
	end

	return refs.__namecall(...)
end)
```

---

## hookfunction

```lua
function hookfunction<T>(func: T, hook: function): T
```

Replaces `func` with `hook` internally, where `hook` will be invoked in place of `func` when called.

Returns a new function that can be used to access the original definition of `func`.

> ### ⚠️ Warning
> If `func` is a Luau function (`islclosure(func) --> true`), the upvalue count of `hook` must be less than or equal to that of `func`.\
> Read more about upvalues on [Lua visibility rules](http://www.lua.org/manual/5.1/manual.html#2.6).

### Parameters

 * `func` - The function to hook.
 * `hook` - The function to redirect calls to.

### Aliases

 * `replaceclosure`

### Example

```lua
local function foo()
	print("Hello, world!")
end

local fooRef = hookfunction(foo, function(...)
	print("Hooked!")
end)

foo() --> Hooked!
fooRef() --> Hello, world!
```

---

## iscclosure

```lua
function iscclosure(func: function): boolean
```

Returns whether or not `func` is a closure whose source is written in C.

### Parameters

 * `func` - The function to check.

### Example

```lua
print(iscclosure(print)) --> true
print(iscclosure(function() end)) --> false
```

---

## islclosure

```lua
function islclosure(func: function): boolean
```

Returns whether or not `func` is a closure whose source is written in Luau.

### Parameters

 * `func` - The function to check.

### Example

```lua
print(islclosure(print)) --> false
print(islclosure(function() end)) --> true
```

---

## isexecutorclosure

```lua
function isexecutorclosure(func: function): boolean
```

Returns whether or not `func` was created by the executor.

### Parameters

 * `func` - The function to check.

### Aliases

 * `checkclosure`
 * `isourclosure`

### Example

```lua
print(isexecutorclosure(isexecutorclosure)) --> true
print(isexecutorclosure(function() end)) --> true
print(isexecutorclosure(print)) --> false
```

---

## loadstring

```lua
function loadstring(source: string, chunkname: string?): (function?, string?)
```

Generates a chunk from the given source code. The environment of the returned function is the global environment.

If there are no compilation errors, the chunk is returned by itself; otherwise, it returns `nil` plus the error message.

`chunkname` is used as the chunk name for error messages and debug information. When absent, it defaults to a **random string**.

> ### ⛔ Danger
> Vanilla Lua allows `source` to contain Lua bytecode, but it is a security vulnerability.\
> This is a feature that should not be implemented.

### Parameters

 * `source` - The source code to compile.
 * `chunkname` - Optional name of the chunk.

### Example

```lua
local func, err = loadstring("print('Hello, world!')")
assert(func, err)() --> Hello, world!

local func, err = loadstring("print('Hello")
assert(func, err)() --> Errors "Malformed string"
```

---

## newcclosure

```lua
function newcclosure<T>(func: T): T
```

Returns a C closure that wraps `func`. The result is functionally identical to `func`, but identifies as a C closure, and may have different metadata.

> ### ⚠️ Warning
> Attempting to yield inside a C closure will throw an error.\
> Instead, use the task library to defer actions to different threads.

### Parameters

 * `func` - The function to wrap.

### Example

```lua
local foo = function() end
local bar = newcclosure(foo)

print(iscclosure(foo)) --> false
print(iscclosure(bar)) --> true
```


# Console

The **console** functions are used to interact with one console window.

Behavior and examples documented on this page are based on Script-Ware.

---

## rconsoleclear

```lua
function rconsoleclear(): ()
```

Clears the output of the console window.

### Aliases

 * `consoleclear`

### Example

```lua
-- Create the console window
rconsolesettitle("New console")
rconsoleprint("Hello, world!")
rconsolecreate()

-- Clears the output "Hello, world!"
rconsoleclear()
```

---

## rconsolecreate

```lua
function rconsolecreate(): ()
```

Opens the console window. Text previously output to the console will not be cleared.

> ### 🔎 Note
> Some executors also allow functions like `rconsoleprint` to open the console.\
> This is confusing behavior that should not be relied on.

### Aliases

 * `consolecreate`

### Example

Create a program that generates a mountainous landscape:

```lua
-- Create the console window
rconsolesettitle("Beautiful Mountains")
rconsolecreate()

local function generate()
	-- Generate a random decimal number for noise
	local seed = math.random(100, 999) + math.random()

	-- Prints 25 lines of text
	for i = 1, 25 do
		local noise = math.noise(i / 8, seed) + 0.5
		local height = math.floor(noise * 50)
		local line = string.rep("*", height)
		rconsoleprint(line .. "\n")
	end

	-- Prompts the user to generate a new set of mountains
	-- or exit the console window
	rconsoleprint("\nEnter 'Y' to generate a new landscape, or nothing to exit\n")

	local input = rconsoleinput()

	if string.lower(input) == "y" then
		rconsoleclear()
		generate()
	else
		rconsoledestroy()
	end
end

generate()
```

---

## rconsoledestroy

```lua
function rconsoledestroy(): ()
```

Closes the console window and clears its output. The title will not be changed.

### Aliases

 * `consoledestroy`

### Example

```lua
-- Create a console window titled "New console" and with the output "Hello, world!"
rconsolesettitle("New console")
rconsoleprint("Hello, world!")
rconsolecreate()

-- Close the console window, clearing its output
rconsoledestroy()

-- Reopen the console window titled "New console" with no output
rconsolecreate()
```

---

## rconsoleinput

`⏰ Yields`

```lua
function rconsoleinput(): string
```

Waits for the user to input text into the console window. Returns the result.

### Aliases

 * `consoleinput`

### Example

```lua
-- Create the console window
rconsolesettitle("Your Info")
rconsoleprint("What is your name?\nMy name is: ")
rconsolecreate()

-- Retrieve the user's input
local name = rconsoleinput()
rconsoleprint("Hello, " .. name .. "!")

-- Cleanup
task.wait(1)
rconsoledestroy()
```

---

## rconsoleprint

```lua
function rconsoleprint(text: string): ()
```

Prints `text` to the console window. Does not clear existing text or create a new line.

### Parameters

* `text` - The text to append to the output.

### Aliases

 * `consoleprint`

### Example

```lua
-- Create a console window titled "New console" with the
-- output "Hello, world!! How are you today?"
rconsolesettitle("New console")
rconsoleprint("Hello, world!")
rconsoleprint("! How are you today?")
rconsolecreate()
```

---

## rconsolesettitle

```lua
function rconsolesettitle(title: string): ()
```

Sets the title of the console window to `title`.

### Parameters

 * `title` - The new title.

### Aliases

 * `rconsolename`
 * `consolesettitle`

### Example

```lua
-- Create a console window titled "My console"
rconsolesettitle("My console")
rconsolecreate()
```


# Crypt

The **crypt** library provides methods for the encryption and decryption of string data.

Behavior and examples documented on this page are based on Script-Ware.

---

## crypt.base64encode

```lua
function crypt.base64encode(data: string): string
```

Encodes a string of bytes into Base64.

### Parameters

 * `data` - The data to encode.

### Aliases

 * `crypt.base64.encode`
 * `crypt.base64_encode`
 * `base64.encode`
 * `base64_encode`

### Example

```lua
local base64 = crypt.base64encode("Hello, World!")
local raw = crypt.base64decode(base64)

print(base64) --> SGVsbG8sIFdvcmxkIQ==
print(raw) --> Hello, World!
```

---

## crypt.base64decode

```lua
function crypt.base64decode(data: string): string
```

Decodes a Base64 string to a string of bytes.

### Parameters

 * `data` - The data to decode.

### Aliases

 * `crypt.base64.decode`
 * `crypt.base64_decode`
 * `base64.decode`
 * `base64_decode`

### Example

```lua
local base64 = crypt.base64encode("Hello, World!")
local raw = crypt.base64decode(base64)

print(base64) --> SGVsbG8sIFdvcmxkIQ==
print(raw) --> Hello, World!
```

---

## crypt.encrypt

`🪲 Compatibility` `🔎 RFC`

```lua
function crypt.encrypt(data: string, key: string, iv: string?, mode: string?): (string, string)
```

Encrypts an unencoded string using AES encryption. Returns the base64 encoded and encrypted string, and the IV.

If an AES IV is not provided, a random one will be generated for you, and returned as a 2nd base64 encoded string.

The cipher modes are 'CBC', 'ECB', 'CTR', 'CFB', 'OFB', and 'GCM'. The default is 'CBC'.

> ### 🪲 Compatibility issues
> Too few executors support this function and a reliable example cannot be made.

### Parameters

 * `data` - The unencoded content.
 * `key` - A base64 256-bit key.
 * `iv` - Optional base64 AES initialization vector.
 * `mode` - The AES cipher mode.

---

## crypt.decrypt

`🪲 Compatibility` `🔎 RFC`

```lua
function crypt.decrypt(data: string, key: string, iv: string, mode: string): string
```

Decrypts the base64 encoded and encrypted content. Returns the raw string.

The cipher modes are 'CBC', 'ECB', 'CTR', 'CFB', 'OFB', and 'GCM'.

> ### 🪲 Compatibility issues
> Too few executors support this function and a reliable example cannot be made.

### Parameters

 * `data` - The base64 encoded and encrypted content.
 * `key` - A base64 256-bit key.
 * `iv` - The base64 AES initialization vector.
 * `mode` - The AES cipher mode.

---

## crypt.generatebytes

```lua
function crypt.generatebytes(size: number): string
```

Generates a random sequence of bytes of the given size. Returns the sequence as a base64 encoded string.

### Parameters

 * `size` - The number of bytes to generate.

### Example

```lua
local bytes = crypt.generatebytes(16)
print(bytes) --> bXlzcWwgYm9vbGVhbnM=
print(#crypt.base64decode(bytes)) --> 16
```

---

## crypt.generatekey

```lua
function crypt.generatekey(): string
```

Generates a base64 encoded 256-bit key. The result can be used as the second parameter for the `crypt.encrypt` and `crypt.decrypt` functions.

### Example

```lua
local bytes = crypt.generatekey()
print(#crypt.base64decode(bytes)) --> 32 (256 bits)
```

---

## crypt.hash

```lua
function crypt.hash(data: string, algorithm: string): string
```

Returns the result of hashing the data using the given algorithm.

Some algorithms include 'sha1', 'sha384', 'sha512', 'md5', 'sha256', 'sha3-224', 'sha3-256', and 'sha3-512'.

### Parameters

 * `data` - The unencoded content.
 * `algorithm` - A hash algorithm.

### Example

```lua
local hash = crypt.hash("Hello, World!", "md5")
print(hash) --> 65A8E27D8879283831B664BD8B7F0AD4
```


# Debug

The **debug** library is an extension of the Luau debug library, providing greater control over Luau functions.

---

## debug.getconstant

`⛔ Exception`

```lua
function debug.getconstant(func: function | number, index: number): any
```

Returns the constant at `index` in the constant table of the function or level `func`. Throws an error if the constant does not exist.

### Parameters

 * `func` - A function or stack level.
 * `index` - The numerical index of the constant to retrieve.

### Example

```lua
local function foo()
	print("Hello, world!")
end

print(debug.getconstant(foo, 1)) --> "print"
print(debug.getconstant(foo, 2)) --> nil
print(debug.getconstant(foo, 3)) --> "Hello, world!"
```

---

## debug.getconstants

```lua
function debug.getconstants(func: function | number): {any}
```

Returns the constant table of the function or level `func`.

> ### 🔎 Tip
> Traversing the table with `ipairs` is not recommended, as constants can be `nil` or skipped entirely.

### Parameters

 * `func` - A function or stack level.

### Example

```lua
local function foo()
	local num = 5000 .. 50000
	print("Hello, world!", num, warn)
end

for i, v in pairs(debug.getconstants(foo)) do
	print(i, v)
end
--> 1 50000
--> 2 "print"
--> 4 "Hello, world!"
--> 5 "warn"
```

---

## debug.getinfo

`🪲 Inconsistent`

```lua
function debug.getinfo(func: function | number): DebugInfo
```

Returns debugger information about a function or stack level.

### DebugInfo

| Field | Type | Description |
| ----- | ---- | ----------- |
| `source` | string | The name of the chunk that created the function. |
| `short_src` | string | A "printable" version of `source` to be used in error messages. |
| `func` | function | The function itself. |
| `what` | string | The string "Lua" if the function is a Luau function, or "C" if it is a C function. |
| `currentline` | number | The current line where the given function is executing. When no line information is available, `currentline` is set to -1. |
| `name` | string | The name of the function. If it cannot find a name, then `name` is a blank string. |
| `nups` | number | The number of upvalues in the function. |
| `numparams` | number | The number of parameters in the function (always 0 for C functions). |
| `is_vararg` | number | Whether the function has a variadic argument (1 if it does, 0 if it does not). |

> ### 🪲 Compatibility
> Some executors are missing certain fields.

### Parameters

 * `func` - A function or stack level.

### Example

```lua
local function foo()
	print("Hello, world!")
end

for k, v in pairs(debug.getinfo(foo)) do
	print(k, v, "(" .. type(v) .. ")")
end
```

---

## debug.getproto

`⛔ Exception` `🛡️ Security`

```lua
function debug.getproto(func: function | number, index: number, active: boolean?): function | {function}
```

Returns the proto at `index` in the function or level `func` if `active` is false.

If `active` is true, then every active function of the proto is returned.

> ### 🛡️ Security
> In some executors, the proto is non-functional if `active` is false. Debug information is preserved.\
> To retrieve a callable function, you can set `active` to true and index the first proto.

### Parameters

 * `func` - A function or stack level.
 * `index` - The numerical index of the proto to retrieve.
 * `active` - Whether to return its list of active closures.

### Example

```lua
local function myFunction()
	local function proto()
		print("Hello, world!")
	end
end

local proto = debug.getproto(myFunction, 1, true)[1]
proto() --> Hello, world!
```

---

## debug.getprotos

`🛡️ Security`

```lua
function debug.getprotos(func: function | number): {function}
```

Returns a list of protos of the function or level `func`.

> ### 🛡️ Security
> In some executors, the proto is non-functional, but debug information is preserved.\
> To retrieve a callable function, see [`debug.getproto`](#debuggetproto).

### Parameters

 * `func` - A function or stack level.

### Example

```lua
local function myFunction()
	local function _1()
		print("Hello,")
	end
	local function _2()
		print("world!")
	end
end

for i in ipairs(debug.getprotos(myFunction)) do
	local proto = debug.getproto(myFunction, i, true)[1]
	proto()
end
--> Hello,
--> world!
```

---

## debug.getstack

`⛔ Exception`

```lua
function debug.getstack(level: number, index: number?): any | {any}
```

Returns the value at `index` in the stack frame `level`. Throws an error if no value could be found.

If `index` is not specified, then the entire stack frame is returned.

### Parameters

 * `level` - The stack frame to look up.
 * `index` - The numerical index of the value to retrieve.

### Example

```lua
local _ = "a" .. "b"
print(debug.getstack(1, 1)) --> ab
```

```lua
local _ = "a" .. "b"
table.foreach(debug.getstack(1), print)
--> ab
--> table.foreach()
--> debug.getstack()
--> 1
```

---

## debug.getupvalue

`⛔ Exception`

```lua
function debug.getupvalue(func: function | number, index: number): any
```

Returns the upvalue at `index` in the function or level `func`. Throws an error if the upvalue does not exist.

An upvalue is a local variable used by an inner function, and is also called an *external local variable*.

Read more on [Lua visibility rules](http://www.lua.org/manual/5.1/manual.html#2.6).

> ### 🔎 Note
> Some Luau optimizations automatically inline certain constants like strings and integers.\
> They can be retrieved through [`debug.getconstant`](#debuggetconstant) instead.

### Parameters

 * `func` - A function or stack level.
 * `index` - The numerical index of the upvalue to retrieve.

### Example

```lua
local upvalue = function ()
end

local function foo()
	print(upvalue)
end

print(debug.getupvalue(foo, 1)) --> upvalue
```

An example of Luau optimization:

```lua
local upvalue = "Hello, world!"

local function foo()
	print(upvalue)
end

print(debug.getupvalue(foo, 1)) --> Errors "upvalue index out of range"
print(debug.getconstant(foo, 3)) --> Hello, world!
```

---

## debug.getupvalues

```lua
function debug.getupvalues(func: function | number): {any}
```

Returns a list of upvalues of the function or level `func`.

> ### 🔎 Tip
> Traversing the table with `ipairs` is not recommended, as upvalues can be `nil` or skipped entirely.

### Parameters

 * `func` - A function or stack level.

### Example

```lua
local upvalue1, upvalue2 = function () end, function () end

local function foo()
	print(upvalue1, upvalue2)
end

for k, v in pairs(debug.getupvalues(foo)) do
	print(k, v, "(" .. type(v) .. ")")
end
--> 1 upvalue1() (function)
--> 2 upvalue2() (function)
```

---

## debug.setconstant

`⛔ Exception`

```lua
function debug.setconstant(func: function | number, index: number, value: any): ()
```

Sets the constant at `index` in the function or level `func` to `value`.

> ### ⛔ Exception
> The type of `value` must match the type of the constant at `index`.

### Parameters

 * `func` - A function or stack level.
 * `index` - The numerical index of the constant to set.
 * `value` - The value to set.

### Example

```lua
local function foo()
	print("Goodbye, world!")
end

debug.setconstant(foo, 3, "Hello, world!")
foo() --> Hello, world!
```

---

## debug.setstack

`⛔ Exception`

```lua
function debug.setstack(level: number, index: number, value: any): ()
```

Sets the register at `index` in the stack frame `level` to `value`.

> ### ⛔ Exception
> The type of `value` must match the type of the register at `index`.

### Parameters

 * `level` - The stack frame to look up.
 * `index` - The numerical index of the register to set.
 * `value` - The value to set.

### Example

```lua
local function foo()
	-- Change the first value from "Goodbye, world!" to "Hello, world!"
	return "Goodbye, world!", debug.setstack(1, 1, "Hello, world!")
end

print(foo()) --> Hello, world!
```

---

## debug.setupvalue

```lua
function debug.setupvalue(func: function | number, index: number, value: any): ()
```

Sets the upvalue at `index` in the function or level `func` to `value`.

### Parameters

 * `func` - A function or stack level.
 * `index` - The numerical index of the upvalue to set.
 * `value` - The value to set.

### Example

```lua
local function somethingImportant()
	print("Goodbye, world!")
end

local function foo()
	somethingImportant()
end

debug.setupvalue(foo, 1, function ()
	print("Hello, world!")
end)

foo() --> Hello, world!
```



# Drawing

The **Drawing** class provides an interface for drawing shapes and text above the game window.

---

## Drawing.new

`🏛️ Constructor`

```lua
function Drawing.new(type: string): Drawing
```

Create a new drawing object of the specified type.

The possible types are 'Line', 'Text', 'Image', 'Circle', 'Square', 'Quad', and 'Triangle'.

### Parameters

 * `type` - The type of drawing object to create.

### Example

```lua
local circle = Drawing.new("Circle")
circle.Radius = 50
circle.Color = Color3.fromRGB(255, 0, 0)
circle.Filled = true
circle.NumSides = 32
circle.Position = Vector2.new(300, 300)
circle.Transparency = 0.7
circle.Visible = true

task.wait(1)
circle:Destroy()
```

---

## Drawing.Fonts

`⭕ Static` `🔒 Read-only`

```lua
Drawing.Fonts: {
	UI: 0,
	System: 1,
	Plex: 2,
	Monospace: 3,
}
```

A table containing the available font names. The style of each font varies depending on the executor.

### Fonts

<details>
<summary>Show font table</summary>

> | Executor | Fonts |
> | --------- | ----- |
> | Script-Ware | ![Script-Ware Fonts](../images/fonts-sw.png) |
> | Krnl | ![Krnl Fonts](../images/fonts-krnl.png) |
</details>

### Example

```lua
for name, font in pairs(Drawing.Fonts) do
	local text = Drawing.new("Text")
	text.Text = "The quick brown fox (" .. name .. ")"
	text.Font = font
	text.Size = 48
	text.Position = Vector2.new(150, 100 + font * 50)
	text.Visible = true
	task.delay(2, function ()
		text:Destroy()
	end)
end
```

---

## Drawing

`🖥️ Class`

```lua
drawing = Drawing.new(type)
```

### BaseDrawing

The base class of which all drawing objects inherit. Cannot be instantiated.

| Property | Type | Description |
| -------- | ---- | ----------- |
| `Visible` | boolean | Whether the drawing is visible. Defaults to `false` on some executors. |
| `ZIndex` | number | Determines the order in which a Drawing renders relative to other drawings. |
| `Transparency` | number | The opacity of the drawing (1 is opaque, 0 is transparent). |
| `Color` | Color3 | The color of the drawing. |
| `Destroy(): ()` | function | Destroys the drawing. |

### Line

Renders a line starting at `From` and ending at `To`.

| Property | Type | Description |
| -------- | ---- | ----------- |
| `From` | Vector2 | The starting point of the line. |
| `To` | Vector2 | The ending point of the line. |
| `Thickness` | number | The thickness of the line. |

### Text

Renders text at `Position`.

| Property | Type | Description |
| -------- | ---- | ----------- |
| `Text` | string | The text to render. |
| `TextBounds` | 🔒 Vector2 | The size of the text. Cannot be set. |
| `Font` | Drawing.Font | The font to use. |
| `Size` | number | The size of the text. |
| `Position` | Vector2 | The position of the text. |
| `Center` | boolean | Whether the text should be centered horizontally. |
| `Outline` | boolean | Whether the text should be outlined. |
| `OutlineColor` | Color3 | The color of the outline. |

### Image

Draws the image data to the screen. `Data` *must* be the raw image data.

| Property | Type | Description |
| -------- | ---- | ----------- |
| `Data` | string | The raw image data. |
| `Size` | Vector2 | The size of the image. |
| `Position` | Vector2 | The position of the image. |
| `Rounding` | number | The rounding of the image. |

### Circle

Draws a circle that is centered at `Position`.

This is not a perfect circle! The greater the value for `NumSides`, the more accurate the circle will be.

| Property | Type | Description |
| -------- | ---- | ----------- |
| `NumSides` | number | The number of sides of the circle. |
| `Radius` | number | The radius of the circle. |
| `Position` | Vector2 | The position of the center of the circle. |
| `Thickness` | number | If `Filled` is false, specifies the thickness of the outline. |
| `Filled` | boolean | Whether the circle should be filled. |

### Square

Draws a rectangle starting at `Position` and ending at `Position` + `Size`.

| Property | Type | Description |
| -------- | ---- | ----------- |
| `Size` | Vector2 | The size of the square. |
| `Position` | Vector2 | The position of the top-left corner of the square. |
| `Thickness` | number | If `Filled` is false, specifies the thickness of the outline. |
| `Filled` | boolean | Whether the square should be filled. |

### Quad

Draws a four-sided figure connecting to each of the four points.

| Property | Type | Description |
| -------- | ---- | ----------- |
| `PointA` | Vector2 | The first point. |
| `PointB` | Vector2 | The second point. |
| `PointC` | Vector2 | The third point. |
| `PointD` | Vector2 | The fourth point. |
| `Thickness` | number | If `Filled` is false, specifies the thickness of the outline. |
| `Filled` | boolean | Whether the quad should be filled. |

### Triangle

Draws a triangle connecting to each of the three points.

| Property | Type | Description |
| -------- | ---- | ----------- |
| `PointA` | Vector2 | The first point. |
| `PointB` | Vector2 | The second point. |
| `PointC` | Vector2 | The third point. |
| `Thickness` | number | If `Filled` is false, specifies the thickness of the outline. |
| `Filled` | boolean | Whether the triangle should be filled. |

---

## cleardrawcache

`🌎 Global`

```lua
function cleardrawcache(): ()
```

Destroys every drawing object in the cache. Invalidates references to the drawing objects.

### Example

```lua
for i = 1, 10 do
	local circle = Drawing.new("Circle")
	circle.Radius = 50
	circle.Color = Color3.fromRGB(255, 0, 0)
	circle.Filled = true
	circle.NumSides = 32
	circle.Position = Vector2.new(math.random(300, 1200), math.random(300, 1200))
	circle.Transparency = 0.7
	circle.Visible = true
end

task.wait(1)
cleardrawcache()
```

---

## getrenderproperty

`🌎 Global`

```lua
function getrenderproperty(drawing: Drawing, property: string): any
```

Gets the value of a property of a drawing. Functionally identical to `drawing[property]`.

### Parameters

 * `drawing` - The drawing to get the property of.
 * `property` - The property to get.

### Example

```lua
local circle = Drawing.new("Circle")
getrenderproperty(circle, "Color")
```

---

## isrenderobj

`🌎 Global`

```lua
function isrenderobj(object: any): boolean
```

Returns whether the given object is a valid Drawing.

### Parameters

 * `object` - Any object.

### Example

```lua
print(isrenderobj(Drawing.new("Circle"))) --> true
print(isrenderobj({})) --> false
```

---

## setrenderproperty

`🌎 Global`

```lua
function setrenderproperty(drawing: Drawing, property: string, value: any): ()
```

Sets the value of a property of a drawing. Functionally identical to `drawing[property] = value`.

### Parameters

 * `drawing` - The drawing to set the property of.
 * `property` - The property to set.
 * `value` - The value to set the property to.

### Example

```lua
local circle = Drawing.new("Circle")
setrenderproperty(circle, "Color", Color3.fromRGB(255, 0, 0))
```


# Filesystem

The **filesystem** functions allow read and write access to a designated folder in the directory of the executor, typically called *workspace*.

---

## readfile

```lua
function readfile(path: string): string
```

Returns the contents of the file located at `path`.

### Parameters

 * `path` - The path to the file.

### Example

```lua
writefile("file.txt", "Hello, world!")
print(readfile("file.txt")) --> Hello, world!
```

---

## listfiles

```lua
function listfiles(path: string): {string}
```

Returns a list of files and folders in the folder located at `path`. The returned list contains whole paths.

### Parameters

 * `path` - The path to the folder.

### Example

Prints every file and folder in *workspace*.

```lua
local function descend(path, level)
	level = level or 0
	for _, file in ipairs(listfiles(path)) do
		print(string.rep("  ", level) .. file)
		if isfolder(file) then
			descend(file, level + 1)
		end
	end
end

descend(".")
```

---

## writefile

```lua
function writefile(path: string, data: string): ()
```

Writes `data` to the file located at `path` if it is not a folder.

### Parameters

 * `path` - A path to the file.
 * `data` - The data to write.

### Example

```lua
writefile("file.txt", "Hello, world!")
print(readfile("file.txt")) --> Hello, world!
```

---

## makefolder

```lua
function makefolder(path: string): ()
```

Creates a folder at `path` if it does not already exist.

### Parameters

 * `path` - The target location.

### Example

```lua
makefolder("folder")
writefile("folder/file.txt", "Hello, world!")
print(readfile("folder/file.txt")) --> Hello, world!
```

---

## appendfile

```lua
function appendfile(path: string, data: string): ()
```

Appends `data` to the end of the file located at `path`. Creates the file if it does not exist.

### Parameters

 * `path` - A path to the file.
 * `data` - The data to append.

### Example

```lua
writefile("services.txt", "A list of services:\n")

for _, service in ipairs(game:GetChildren()) do
	if service.ClassName ~= "" then
		appendfile("services.txt", service.ClassName .. "\n")
	end
end
```

---

## isfile

```lua
function isfile(path: string): boolean
```

Returns whether or not `path` points to a file.

### Parameters

 * `path` - The path to check.

### Example

```lua
writefile("file.txt", "Hello, world!")
print(isfile("file.txt")) --> true
```

---

## isfolder

```lua
function isfolder(path: string): boolean
```

Returns whether or not `path` points to a folder.

### Parameters

 * `path` - The path to check.

### Example

```lua
makefolder("folder")
print(isfolder("folder")) --> true
```

---

## delfile

```lua
function delfile(path: string): ()
```

Removes the file located at `path`.

### Parameters

 * `path` - The path to the file.

### Example

```lua
writefile("file.txt", "Hello, world!")
print(isfile("file.txt")) --> true

delfile("file.txt")
print(isfile("file.txt")) --> false
```

---

## delfolder

```lua
function delfolder(path: string): ()
```

Removes the folder located at `path`.

### Parameters

 * `path` - The path to the folder.

### Example

```lua
makefolder("folder")
print(isfolder("folder")) --> true

delfolder("folder")
print(isfolder("folder")) --> false
```

---

## loadfile

```lua
function loadfile(path: string, chunkname: string?): (function?, string?)
```

Generates a chunk from the file located at `path`. The environment of the returned function is the global environment.

If there are no compilation errors, the chunk is returned by itself; otherwise, it returns `nil` plus the error message.

`chunkname` is used as the chunk name for error messages and debug information. When absent, it defaults to a **random string**.

### Parameters

 * `path` - A path to the file containing Luau code.
 * `chunkname` - Optional name of the chunk.

### Example

```lua
writefile("file.lua", "local number = ...; return number + 1")
local func, err = loadfile("file.lua")
local output = assert(func, err)(1)
print(output) --> 2
```

---

## dofile

```lua
function dofile(path: string): ()
```

Attempts to load the file located at `path` and execute it on a new thread.

> ### 🔎 Note
> Some executors may provide the file name to the top-level vararg of the file (`...`).

### Parameters

 * `path` - The path to the file.

### Example

```lua
writefile("code.lua", "print('Hello, world!')")
dofile("code.lua") --> "Hello, world!"
```



# Input

The **input** functions allow you to dispatch inputs on behalf of the user.

---

## isrbxactive

```lua
function isrbxactive(): boolean
```

Returns whether the game's window is in focus. Must be true for other input functions to work.

### Aliases

 * `isgameactive`

### Example

```lua
if isrbxactive() then
	mouse1click()
end
```

---

## mouse1click

```lua
function mouse1click(): ()
```

Dispatches a left mouse button click.

---

## mouse1press

```lua
function mouse1press(): ()
```

Dispatches a left mouse button press.

---

## mouse1release

```lua
function mouse1release(): ()
```

Dispatches a left mouse button release.

---

## mouse2click

```lua
function mouse2click(): ()
```

Dispatches a right mouse button click.

---

## mouse2press

```lua
function mouse2press(): ()
```

Dispatches a right mouse button press.

---

## mouse2release

```lua
function mouse2release(): ()
```

Dispatches a right mouse button release.

---

## mousemoveabs

```lua
function mousemoveabs(x: number, y: number): ()
```

Moves the mouse cursor to the specified absolute position.

### Parameters

 * `x` - The x-coordinate of the mouse cursor.
 * `y` - The y-coordinate of the mouse cursor.

### Example

Move the cursor in a circle around the screen:

```lua
-- Wait for the game window to be selected
while not isrbxactive() do
	task.wait()
end

local size = workspace.CurrentCamera.ViewportSize
	
for i = 0, 50 do
	local x = math.sin(i / 50 * math.pi * 2) / 2 + 0.5
	local y = math.cos(i / 50 * math.pi * 2) / 2 + 0.5
	mousemoveabs(x * size.X, y * size.Y)
	task.wait(0.05)
end
```

---

## mousemoverel

```lua
function mousemoverel(x: number, y: number): ()
```

Adjusts the mouse cursor by the specified relative amount.

### Parameters

 * `x` - The x-offset of the mouse cursor.
 * `y` - The y-offset of the mouse cursor.

### Example

Moves the cursor in a small circle:

```lua
-- Wait for the game window to be selected
while not isrbxactive() do
	task.wait()
end

for i = 0, 20 do
	local x = math.sin(i / 20 * math.pi * 2)
	local y = math.cos(i / 20 * math.pi * 2)
	mousemoverel(x * 100, y * 100)
	task.wait(0.05)
end
```

---

## mousescroll

```lua
function mousescroll(pixels: number): ()
```

Dispatches a mouse scroll by the specified number of pixels.

### Parameters

 * `pixels` - The number of pixels to scroll.


# Instances

The **Instance** functions are used to interact with game objects and their properties.

---

## fireclickdetector

```lua
function fireclickdetector(object: ClickDetector, distance: number?, event: string?): ()
```

Dispatches a click or hover event to the given ClickDetector. When absent, `distance` defaults to zero, and `event` defaults to "MouseClick".

Possible input events include 'MouseClick', 'RightMouseClick', 'MouseHoverEnter', and 'MouseHoverLeave'.

### Parameters

 * `object` - The ClickDetector to dispatch to.
 * `distance` - Optional distance to the object.
 * `event` - Optional event to fire.

### Example

```lua
local clickDetector = workspace.Door.Button.ClickDetector
fireclickdetector(clickDetector, 10 + math.random(), "MouseClick")
```

---

## getcallbackvalue

```lua
function getcallbackvalue(object: Instance, property: string): function?
```

Returns the function assigned to a callback property of `object`, which cannot be indexed normally.

### Parameters

 * `object` - The object to get the callback property from.
 * `property` - The name of the callback property.

### Example

```lua
local bindable = Instance.new("BindableFunction")

function bindable.OnInvoke()
	print("Hello, world!")
end

print(getcallbackvalue(bindable, "OnInvoke")) --> function()
print(bindable.OnInvoke) --> Throws an error
```

---

## getconnections

```lua
function getconnections(signal: RBXScriptSignal): {Connection}
```

Creates a list of Connection objects for the functions connected to `signal`.

### Connection

| Field | Type | Description |
| ----- | ---- | ----------- |
| `Enabled` | boolean | Whether the connection can receive events. |
| `ForeignState` | boolean | Whether the function was connected by a foreign Luau state (i.e. CoreScripts). |
| `LuaConnection` | boolean | Whether the connection was created in Luau code. |
| `Function` | function? | The function bound to this connection. Nil when `ForeignState` is true. |
| `Thread` | thread? | The thread that created the connection. Nil when `ForeignState` is true. |

| Method | Description |
| ----- | ----------- |
| `Fire(...: any): ()` | Fires this connection with the provided arguments. |
| `Defer(...: any): ()` | [Defers](https://devforum.roblox.com/t/beta-deferred-lua-event-handling/1240569) an event to connection with the provided arguments. |
| `Disconnect(): ()` | Disconnects the connection. |
| `Disable(): ()` | Prevents the connection from firing. |
| `Enable(): ()` | Allows the connection to fire if it was previously disabled. |

### Parameters

 * `signal` - The signal to retrieve connections from.

### Example

```lua
local connections = getconnections(game.DescendantAdded)

for _, connection in ipairs(connections) do
	connection:Disable()
end
```

---

## getcustomasset

```lua
function getcustomasset(path: string, noCache: boolean): string
```

Returns a `rbxasset://` content id for the asset located at `path`, allowing you to use unmoderated assets. Internally, files are copied to the game's content directory.

If `noCache` is false, the file will be cached, allowing subsequent calls to `getcustomasset` to return the same content id.

### Parameters

 * `path` - The path to the asset.
 * `noCache` - Whether or not to cache the asset.

### Example

```lua
local image = Instance.new("ImageLabel")
image.Image = getcustomasset("image.png")
print(image.Image) --> rbxasset://nTYyO6iSF3mND4FJ/image.png
```

---

## gethiddenproperty

```lua
function gethiddenproperty(object: Instance, property: string): (any, boolean)
```

Returns the value of a hidden property of `object`, which cannot be indexed normally.

If the property is hidden, the second return value will be `true`. Otherwise, it will be `false`.

### Parameters

 * `object` - The object to index.
 * `property` - The name of the hidden property.

### Example

```lua
local fire = Instance.new("Fire")
print(gethiddenproperty(fire, "size_xml")) --> 5, true
print(gethiddenproperty(fire, "Size")) --> 5, false
```

---

## gethui

```lua
function gethui(): Folder
```

Returns a hidden GUI container. Should be used as an alternative to CoreGui and PlayerGui.

GUI objects parented to this container will be protected from common detection methods.

### Example

```lua
local gui = game:GetObjects("rbxassetid://1234")[1]
gui.Parent = gethui()
```

---

## getinstances

```lua
function getinstances(): {Instance}
```

Returns a list of every Instance referenced on the client.

### Example

```lua
local objects = getinstances()

local gameCount = 0
local miscCount = 0

for _, object in ipairs(objects) do
	if object:IsDescendantOf(game) then
		gameCount += 1
	else
		miscCount += 1
	end
end

print(gameCount) --> The number of objects in the `game` hierarchy.
print(miscCount) --> The number of objects outside of the `game` hierarchy.
```

---

## getnilinstances

```lua
function getnilinstances(): {Instance}
```

Like `getinstances`, but only includes Instances that are not descendants of a service provider.

### Example

```lua
local objects = getnilinstances()

for _, object in ipairs(objects) do
	if object:IsA("LocalScript") then
		print(object, "is a LocalScript")
	end
end
```

---

## isscriptable

`🪲 Compatibility`

```lua
function isscriptable(object: Instance, property: string): boolean
```

Returns whether the given property is scriptable (does not have the `notscriptable` tag).

If `true`, the property is scriptable and can be indexed normally. If `nil`, the property does not exist.

> ### 🪲 Known Issues
> This appears to be backwards on Script-Ware. An example will not be provided until behavior is consistent.

### Parameters

 * `object` - The object to index.
 * `property` - The name of the property.

---

## sethiddenproperty

```lua
function sethiddenproperty(object: Instance, property: string, value: any): boolean
```

Sets the value of a hidden property of `object`, which cannot be set normally. Returns whether the property was hidden.

### Parameters

 * `object` - The object to index.
 * `property` - The name of the hidden property.
 * `value` - The value to set.

### Example

```lua
local fire = Instance.new("Fire")
print(sethiddenproperty(fire, "Size", 5)) --> false (not hidden)
print(sethiddenproperty(fire, "size_xml", 15)) --> true (hidden)
print(gethiddenproperty(fire, "size_xml")) --> 15, true (hidden)
```

---

## setrbxclipboard

```lua
function setrbxclipboard(data: string): boolean
```

Sets the Studio client's clipboard to the given `rbxm` or `rbxmx` model data. This allows data from the game to be copied into a Studio client.

### Parameters

 * `data` - The model data to copy to the clipboard.

### Example

```lua
local data = readfile("model.rbxm")
setrbxclipboard(data) -- Can be pasted into Studio
```

---

## setscriptable

`🪲 Compatibility`

```lua
function setscriptable(object: Instance, property: string, value: boolean): boolean
```

Set whether the given property is scriptable. Returns whether the property was scriptable prior to changing it.

> ### 🪲 Known Issues
> This appears to be backwards on Script-Ware. An example will not be provided until behavior is consistent.

### Parameters

 * `object` - The object to index.
 * `property` - The name of the property.
 * `value` - Whether the property should be scriptable.


# Metatable

The **metatable** functions allow elevated access to locked metatables.

---

## getrawmetatable

```lua
function getrawmetatable(object: table): table
```

Returns the metatable of `object`, where the `__metatable` field would normally lock the metatable.

### Parameters

 * `object` - An object with a metatable.

### Example

```lua
local object = setmetatable({}, { __metatable = "Locked!" })
print(getmetatable(object)) --> Locked!
print(getrawmetatable(object)) --> table
```

---

## hookmetamethod

```lua
function hookmetamethod(object: table, method: string, hook: function): function
```

Replaces `func` with `hook` internally, where `hook` will be invoked in place of `func` when called.

Returns a new function that can be used to access the original definition of `func`.

> ### ⚠️ Not yieldable
> The function `hook` is **not** allowed to yield or block the thread.

> ### ⚠️ Recursion
> Try not to invoke `method` from within the function `hook`!\
> For example, do not index a property of an Instance from within a hook to `__index`.

### Parameters

 * `object` - An object with a metatable.
 * `method` - The name of the method to hook.
 * `hook` - The function to replace `func` with.

### Example

Prevent scripts in PlayerGui from invoking the `__namecall` hook:

```lua
local refs = {}
local bannedScripts = game:GetService("Players").LocalPlayer.PlayerGui

refs.__namecall = hookmetamethod(game, "__namecall", function(...)
	local caller = getcallingscript()

	-- Use '.' notation to call the IsDescendantOf method without invoking
	-- __namecall and causing a recursive loop.
	local isBanned = caller.IsDescendantOf(caller, bannedScripts)

	if isBanned then
		error("Not allowed to invoke __namecall")
	end

	return refs.__namecall(...)
end)
```

---

## getnamecallmethod

```lua
function getnamecallmethod(): string
```

Returns the name of the method that invoked the `__namecall` metamethod.

### Example

Bans the use of `game:service()`:

```lua
local refs = {}

refs.__namecall = hookmetamethod(game, "__namecall", function(...)
	local self = ...
	local method = getnamecallmethod()

	if self == game and method == "service" then
		error("Not allowed to run game:service()")
	end

	return refs.__namecall(...)
end)
```

---

## isreadonly

```lua
function isreadonly(object: table): boolean
```

Returns whether `object` is frozen or read-only. Identical to `table.isfrozen`.

### Parameters

 * `object` - A table or userdata.

### Example

```lua
local object = {}
table.freeze(object)
print(isreadonly(object)) --> true
```

---

## setrawmetatable

```lua
function setrawmetatable(object: table, metatable: table): ()
```

Sets the metatable of `object` to `metatable`, where the `__metatable` field would normally lock the metatable.

### Parameters

 * `object` - A table or userdata.
 * `metatable` - The metatable to set.

### Example

```lua
local object = setmetatable({}, {})
print(getmetatable(object)) --> table
setrawmetatable(object, { __metatable = "Hello, world!" })
print(getmetatable(object)) --> Hello, world!
```

---

## setreadonly

```lua
function setreadonly(object: table, readonly: boolean): ()
```

Sets whether `object` is frozen or read-only.

### Parameters

 * `object` - A table or userdata.
 * `readonly` - Whether or not `object` should be frozen.

### Example

```lua
local object = {}

table.freeze(object)
print(isreadonly(object)) --> true

setreadonly(object, false)
print(isreadonly(object)) --> false
```


# WebSocket

The **WebSocket** class provides a simple interface for sending and receiving data over a WebSocket connection.

---

## WebSocket.connect

`🏛️ Constructor`

```lua
function WebSocket.connect(url: string): WebSocket
```

Establishes a WebSocket connection to the specified URL.

### Parameters

 * `url` - The URL to connect to.

### Example

```lua
local ws = WebSocket.connect("ws://localhost:8080")

ws.OnMessage:Connect(function(message)
	print(message)
end)

ws.OnClose:Connect(function()
	print("Closed")
end)

ws:Send("Hello, World!")
```

---

## WebSocket

`🖥️ Class`

```lua
ws = WebSocket.connect(url)
```

### Methods

| Method | Description |
| ------ | ----------- |
| `Send(message: string): ()` | Sends a message over the WebSocket connection. |
| `Close(): ()` | Closes the WebSocket connection. |

### Events

| Event | Description |
| ----- | ----------- |
| `OnMessage(message: string): ()` | Fired when a message is received over the WebSocket connection. |
| `OnClose(): ()` | Fired when the WebSocket connection is closed. |
