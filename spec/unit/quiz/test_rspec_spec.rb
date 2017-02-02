
        describe 'WITHOUT QUESTION MARK AND NON-BREAKING SPACE' do
          let(:t) { "<div><span>récit</span></div>" }
          let(:q) { "récit" }
          it '=> SUCCESS' do
            expect(t).to have_tag('span') do
              with_tag('span', text: q)
            end
          end
        end

        describe 'WITH QUESTION MARK AND COMMON SPACE' do
          let(:t) { "<div><span>récit ?</span></div>" }
          let(:q) { "récit ?" }
          it '=> SUCCESS' do
            expect(t).to have_tag('span') do
              with_tag('span', text: q)
            end
          end
        end


        describe 'WITH QUESTION MARK AND NON-BREAKING SPACE' do
          let(:t) { "<div><span>récit ?</span></div>" }
          let(:q) { "récit ?" }
          it '=> FAILURE' do
            expect(t).to have_tag('span') do
              with_tag('span', text: q)
            end
          end
        end
