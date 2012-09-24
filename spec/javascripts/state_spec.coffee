describe "Proprietas", ->
    it "can be initialized", ->
        expect(-> new ProprietasApp.State()).not.toThrow(new TypeError("undefined is not a function"));