require 'test_helper'

require 'wsdl_mapper/dom/node'

module DomTests
  class NodeTest < Minitest::Test
    include WsdlMapper::Dom

    def test_add_child
      node1 = Node.new nil
      node2 = Node.new nil

      node1.add_child node2

      assert_equal node2, node1.children.first
      assert_equal node2.parent, node1
    end

    def test_root
      node1 = Node.new nil
      node2 = Node.new nil

      node1.add_child node2

      assert node1.root?
      refute node2.root?
    end

    def test_leaf
      node1 = Node.new nil
      node2 = Node.new nil

      node1.add_child node2

      assert node2.leaf?
      refute node1.leaf?
    end
  end
end
