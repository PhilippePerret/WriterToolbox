# encoding: UTF-8
=begin

Test de l'extension de la classe Object pour le test

=end
site.require_module 'test'

class TestObject < Test::Unit::TestCase

  def test_a_string_exactly
    assert("mon test".__test_is?("mon test"))
    assert("mon test".__test_is?("MON TEST"))
    assert("mon test".__test_is?("MON TEST", strict = false))
    assert(!"a string".__test_is?("A STRING", strict = true))
    assert("Mon test".__test_is?("mon test", strict = false))
    assert(!"Mon test".__test_is?("mon test", strict = true))
  end

  def test_a_string_close
    assert("mon test pour voir".__test_has?('test pour'))
    assert(!"mon test pour voir".__test_has?('tester pour'))
    assert(!'mon test pour voir'.__test_has?('TEST POUR', strict=true))
    assert('mon 3e test pour voir'.__test_has?(3))
    assert('Ça fait du 10.2'.__test_has?(10.2))
  end

  def test_a_string_errors
    assert_raise(RuntimeError, 'Un String ne peut pas être comparé à un Fixnum.'){'a string'.__test_is?(12)}
    assert_raise(RuntimeError, 'Un String ne peut pas être comparé à un Float.'){'a string'.__test_is?(12.0)}
    assert_raise(RuntimeError, 'Un String ne peut pas contenir un Array.'){"un string".__test_has?([1,2,3])}
    assert_raise(RuntimeError, 'Un String ne peut pas contenir un Hash.'){"un string".__test_has?({mon: 'hash'})}
  end

  def test_a_number
    assert(12.__test_is?(12))
  end
  def test_a_number_errors
    assert_raise(RuntimeError, 'Un Fixnum ne peut contenir un Fixnum.'){ 12.__test_has?(4) }
  end

  def test_an_array
    assert([1,2,3].__test_is?([1,2,3]))
    assert(![1,2,3].__test_is?([1,2]))
  end
  def test_an_array_errors
    assert_raise(RuntimeError, 'Un Array ne peut pas être comparé à un String.'){ [1,2,3].__test_is?('un string')}
    assert_raise(RuntimeError, 'Un Array ne peut pas être comparé à un Hash.'){[1,2,3].__test_is?(mon: 'Hash')}
    assert_raise(RuntimeError, 'Un Array ne peut pas être comparé à un Fixnum'){[1,2,3].__test_is?(12)}
  end

end
