require 'spec_helper'

module Navigator
  module Renderer
    describe List, type: 'view' do
      let(:element_first_target)   { 'li:first-child a[target="_blank"]' }
      let(:element_first_sub)      { 'li:first-child ul' }
      let(:element_first_selected) { 'li:first-child.selected' }

      let(:element_last_target)    { 'li:last-child a[target="_blank"]' }
      let(:element_last_sub)       { 'li:last-child ul' }
      let(:element_last_selected)  { 'li:last-child.selected' }

      subject { render_result }

      context '.render' do
        context 'renders HTML menu' do
          it 'with the first item having a target' do
            expect(subject).to have_css(element_first_target)
          end

          it 'with the second item not having a target' do
            expect(subject).to_not have_css(element_last_target)
          end

          it 'with the first item not selected' do
            expect(subject).to_not have_css(element_first_selected)
          end

          it 'with the first item not having sub levels' do
            expect(subject).to_not have_css(element_first_sub)
          end

          it 'with the second item having sub levels' do
            expect(subject).to have_css(element_last_sub)
          end

          it 'with the first item not selected' do
            expect(subject).to have_css(element_last_selected)
          end
        end
      end

      def render_result
        setup_adapter_for :rails
        container = SimpleNavigation::ItemContainer.new(1)
        setup_items(container)
        container.render(skip_if_empty: true, expand_all: true)
      end

      def setup_adapter_for(framework)
        context = double(:context, view_context: ActionView::Base.new)
        adapter = SimpleNavigation::Adapters::Rails.new(context)

        SimpleNavigation::Configuration.instance do |config|
          config.renderer = Navigator::Renderer::List
        end

        SimpleNavigation.stub(adapter: adapter)

        SimpleNavigation::Item.any_instance.stub(selected?:              false,
                                                 selected_by_condition?: false )
      end

      def setup_items(container)
        container.item :news, 'News', '/news', {
          id:    'news_item',
          class: 'menu-item menu-item-1',
          link:  {
            target: '_blank'
          }
        }
        container.item :info, 'Info', '/info', {
          id:              'menu_item_2',
          class:           'menu-item menu-item-2',
          container_class: 'menu-children'
          } do |info_nav|
          info_nav.item :main_info_page, "Main info page", '/info/main', {
            id:    'menu_item_3',
            class: 'menu-item menu-item-3'
          }
        end

        container.items.find { |item|
          item.key == :info
        }.stub( selected?: true, selected_by_condition?: true )
      end
    end
  end
end
