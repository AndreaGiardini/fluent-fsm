require! 'should'
require! 'async'
{fsm-tester} = require './fsmexpress.js'

dbg = true 

mdhead  = ->
    if dbg
        console.log ""
    

mdp = (e) ->
    if dbg
        console.log "        ◦ #e"


moment          = require 'moment'

ft = new fsm-tester

describe 'FSM definition', ->
  describe 'State identification', (empty) ->
    mdhead
    it 'derive implicit states',  (done) ->
        ft.create-fsm()
        rules = [
            { from: 'I', jump-to: 'S', at: 'eventx' }
            { from: 'S', jump-to: 'I', at: 'eventy' }
            ] 
        ft.add-rules(rules)
        ft.unfold(\I)
        ft.get-states().should.eql([ \I \S ])
        done()
        
  describe 'Rule identification', (empty) ->
    it 'derive simple rules',  (done) ->
        ft.create-fsm()
        rules = [
            { from: 'I', jump-to: 'S', at: 'eventx' }
            { from: 'S', jump-to: 'I', at: 'eventy' }
            ] 
        ft.add-rules(rules)
        ft.unfold(\I)
        ft.get-exp-rules().should.includeEql(from: \I, to: \S, transition: \eventx)
        done()
    
    it 'derive complex rules (no loop)',  (done) ->
        ft.create-fsm()
        rules = [
            { from: 'I', jump-to: 'S', at: 'eventx' }
            { from: 'S', jump-to: 'I', at: 'eventy' }
            { from: '(.)', jump-to: 'S', at: 'eventy' }
            ] 
        ft.add-rules(rules)
        ft.unfold(\I)
        ft.get-exp-rules().should.includeEql(from: \I, to: \S, transition: \eventy)
        ft.get-exp-rules().should.not.includeEql(from: \S, to: \S, transition: \eventy)
        done()
    
    it 'derive complex rules (loop)',  (done) ->
        ft.create-fsm()
        rules = [
            { from: 'I', jump-to: 'S', at: 'x' }
            { from: 'S', jump-to: 'I', at: 'x' }
            { from: '(.)', jump-to: '-', at: 'y' }
            ] 
        ft.add-rules(rules)
        ft.unfold(\I)
        ft.get-exp-rules().should.includeEql(from: \I, to: \I, transition: \y)
        ft.get-exp-rules().should.includeEql(from: \S, to: \S, transition: \y)
        ft.get-exp-rules().should.not.includeEql(from: \I, to: \S, transition: \y)
        done()

    it 'derive complex rules (with excluding)',  (done) ->
        ft.create-fsm()
        rules = [
            { from: 'I', jump-to: 'S', at: 'x' }
            { from: 'S', jump-to: 'I', at: 'x' }
            { from: '(.)', jump-to: '-', excluding: [ \S ] at: 'y' }
            ] 
        ft.add-rules(rules)
        ft.unfold(\I)
        ft.get-exp-rules().should.includeEql(from: \I, to: \I, transition: \y)
        ft.get-exp-rules().should.not.includeEql(from: \S, to: \S, transition: \y)
        ft.get-exp-rules().should.not.includeEql(from: \I, to: \S, transition: \y)
        done()
        
    it 'derive complex rules (with excluding - alt)',  (done) ->
        ft.create-fsm()
        rules = [
            { from: 'I', jump-to: 'S', at: 'x' }
            { from: 'S', jump-to: 'I', at: 'x' }
            { from: '(.)', jump-to: '-', excluding: \S , at: 'y' }
            ] 
        ft.add-rules(rules)
        ft.unfold(\I)
        ft.get-exp-rules().should.includeEql(from: \I, to: \I, transition: \y)
        ft.get-exp-rules().should.not.includeEql(from: \S, to: \S, transition: \y)
        ft.get-exp-rules().should.not.includeEql(from: \I, to: \S, transition: \y)
        done()
        
              
describe 'FSM operation', ->
  describe 'Simple sequence', (empty) ->
    it 'should run a simple transition',  (done) ->      
        ft.create-fsm()
        rules = [
            { from: 'I', jump-to: 'S', at: 'x' }
            { from: 'S', jump-to: 'I', at: 'x' }
            { from: '(.)', jump-to: '-', at: 'y' }
            ] 
        ft.add-rules(rules)
        ft.unfold(\I)
        ft.run-events [ \x ], ~>
            ft.get-current-state().should.equal(\S)    
            done()

    it 'should run a simple sequence, return to start',  (done) ->      
        ft.create-fsm()
        rules = [
            { from: 'I', jump-to: 'S', at: 'x' }
            { from: 'S', jump-to: 'I', at: 'x' }
            { from: '(.)', jump-to: '-', at: 'y' }
            ] 
        ft.add-rules(rules)
        ft.unfold(\I)
        ft.run-events [ \x \x \y \y ], ~>
            ft.get-current-state().should.equal(\I)    
            done()
        
    it 'should run a simple sequence, no return to start ',  (done) ->      
        ft.create-fsm()
        rules = [
            { from: 'I', jump-to: 'S', at: 'x' }
            { from: 'S', jump-to: 'I', at: 'x' }
            { from: '(.)', jump-to: '-', at: 'y' }
            ] 
        ft.add-rules(rules)
        ft.unfold(\I)
        ft.run-events [ \x \y \y ], ~>
            ft.get-current-state().should.equal(\S)    
            done() 
            
    it 'should not react to events that are not specified ',  (done) ->      
        ft.create-fsm()
        rules = [
            { from: 'I', jump-to: 'S', at: 'x' }
            { from: 'S', jump-to: 'I', at: 'x' }
            { from: '(.)', jump-to: '-', at: 'y' }
            ] 
        ft.add-rules(rules)
        ft.unfold(\I)
        ft.run-events [ \x \y \e \x \y ], ~>
            ft.get-current-state().should.equal(\I)    
            done() 
    
    
    it 'should run a simple sequence, return to start',  (done) ->      
        ft.create-fsm()
        rules = [
            { from: 'I', jump-to: 'S', at: 'x' }
            { from: 'S', jump-to: 'I', at: 'x' }
            { from: '(.)', jump-to: '-', at: 'y' }
            ] 
        ft.add-rules(rules)
        ft.unfold(\I)
        ft.run-events [ \x \x \y \y ], ~>
            ft.get-current-state().should.equal(\I)    
            done()
        
    it 'should run a simple sequence, no return to start ',  (done) ->      
        ft.create-fsm()
        rules = [
            { from: 'I', jump-to: 'S', at: 'x' }
            { from: 'S', jump-to: 'I', at: 'x' }
            { from: '(.)', jump-to: '-', at: 'y' }
            ] 
        ft.add-rules(rules)
        ft.unfold(\I)
        ft.run-events [ \x \y \y ], ~>
            ft.get-current-state().should.equal(\S)    
            done() 
  describe 'Event management', (empty) ->            
    it 'should trigger the correct amount of event functions',  (done) ->      
        ft = null
        ft = new fsm-tester()
        ft.create-fsm()
        count = x: 0, y: 0
        rules = [
            { from: 'I', jump-to: 'S', at: 'x' ,  execute: (-> @x = @x + 1).bind(count)}
            { from: 'S', jump-to: 'I', at: 'x' ,  execute: (-> @x = @x + 1).bind(count)}
            { from: '(.)', jump-to: '-', at: 'y', execute: (-> @y = @y + 1).bind(count)}
            ] 
        ft.add-rules(rules)
        ft.unfold(\I)
        ft.run-events [ \x \y \e \x ], ~>
            count.x.should.be.equal(2)
            count.y.should.be.equal(1)
            ft.get-current-state().should.equal(\I)    
            done() 
    it 'should trigger the correct amount of event functions in the correct order',  ->      
        ft = null
        ft = new fsm-tester()
        ft.create-fsm()
        count = x: 0, y: 0
        rules = [
            { from: 'I', jump-to: 'S', at: 'x' ,  execute: (-> @x = @x + 1).bind(count)}
            { from: 'I', jump-to: 'T', at: 'y' ,  execute: (-> @x = @x + 1).bind(count)}
            ] 
        ft.add-rules(rules)
        ft.unfold(\I)
        ft.fsm.register-event-emitter(ft)
        ft.setMaxListeners(0)
        ft.fsm.start()
        ft.emit(\x)
        ft.emit(\y)
        ft.get-current-state().should.equal(\S)
    it 'should trigger the correct amount of event functions (sync)',  (done) ->      
        ft = null
        ft = new fsm-tester()
        ft.create-fsm()
        count = x: 0, y: 0
        rules = [
            { from: 'I', jump-to: 'S', at: 'x' ,  execute: (-> @x = @x + 1).bind(count)}
            { from: 'S', jump-to: 'I', at: 'x' ,  execute: (-> @x = @x + 1).bind(count)}
            { from: '(.)', jump-to: '-', at: 'y', execute: (-> @y = @y + 1).bind(count)}
            ] 
        ft.add-rules(rules)
        ft.unfold(\I)
        ft.run-events-sync [ \x ]
        count.x.should.be.equal(1)
        count.y.should.be.equal(0)
        ft.get-current-state().should.equal(\S)    
        done() 

