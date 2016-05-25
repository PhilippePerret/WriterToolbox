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

  EGAUX = [
    ["mon string", "mon string"],["mon string", "Mon String"],
    [true, true], [false, false], [nil, nil],
    [ [1,2,3], [1,2,3]],
    [ {un: 'hash'}, {:un => 'hash'} ]
  ]

  DIFFERENTS = [
    [true, false], [false, true], [nil, false], [nil, true],
    [true, nil], [false, nil],
    ["a string", true], ["a string", false], ["a string", nil],
    [12, 13], [12, true], [12, false], [12, nil],
    [ [1,2,3], [1,2]], [ [1,2,3], true], [ [1,2,3], nil],
    [ {un: 'hash'}, { 'un' => 'hash'} ]
  ]

  # Attention, ci-dessous, des valeurs qui pourraient être
  # égales mais qui doivent être fausses avec l'argument strict
  # à true
  STRICTEMENT_DIFFERENTS = [
    ["mon string", "Mon String"]
  ]

  def test_de_is
    assert_respond_to(Object, :is)

    # Assertions qui provoquent une égalité
    EGAUX.each do |pair|
      assert(pair[0].is(pair[1]))
    end

    # Assertions qui provoquent une erreur
    DIFFERENTS.each do |pair|
      assert_raise(TestUnsuccessfull){pair[0].is(pair[1])}
    end

    STRICTEMENT_DIFFERENTS.each do |pair|
      assert_raise(TestUnsuccessfull){pair[0].is(pair[1], strict: true)}
    end

  end

  def test_de_is_not
    assert_respond_to(Object, :is_not)
    assert({un:'hash'}.is_not({'un' => 'hash'}))

    EGAUX.each do |pair|
      assert_raise(TestUnsuccessfull){pair[0].is_not(pair[1])}
    end

    DIFFERENTS.each do |pair|
      assert(pair[0].is_not(pair[1]))
    end

    STRICTEMENT_DIFFERENTS.each do |pair|
      assert(pair[0].is(pair[1]))
      assert(pair[0].is_not(pair[1], strict: true))
    end
  end
end
